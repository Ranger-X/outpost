begin
  require 'net/telnet'
rescue LoadError => e
  puts "Please install net-telnet gem: gem install net-telnet".
  raise
end

require 'outpost/expectations'

module Outpost
  module Scouts
    # Uses telnet to check if the service on server has open port.
    #
    # * Responds to response_time expectation
    #   ({Outpost::Expectations::ResponseTime})
    #
    class STelnet < Outpost::Scout
      extend Outpost::Expectations::ResponseTime
      extend Outpost::Expectations::ResponseBody

      attr_reader :response_time, :response_body
      report_data :response_time, :response_body

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :host The host that will be "pinged".
      # @option options [Number] :port The port that will be checked.
      # @option options [Number] :timeout The timeout of connect attempt. Default: 3s
      # @option options [String] :prompt The prompt which must be returned by telneted service.
      # @option options [String] :command The command to send to service.
      def setup(options)
        @host     = options[:host]
        @port     = options[:port]
        @timeout  = options[:timeout] || 3
        @prompt   = options[:prompt] || '[$%#>] \z'
        @command  = options[:command]
      end

      # Runs the scout, pinging the host and getting the duration.
      def execute
        previous_time = Time.now
        prompt = Regexp.new(@prompt)

        telnet = Net::Telnet::new(
            "Host"       => @host,
            "Port"       => @port,
            "Timeout"    => @timeout,
#            "Waittime"   => @waittime,
            "Binmode"    => true,
            "Telnetmode" => false,
            "Prompt"     => prompt,
        )

        telnet.cmd(@command) { |c| @response_body = c } if @command
        telnet.close

        @response_time = (Time.now - previous_time) * 1000 # Miliseconds
      rescue Exception => e
        @response_time = nil
        @response_body = "Exception on telnet to #{@host}:#{@port}: #{e.message}"
      end
    end
  end
end
