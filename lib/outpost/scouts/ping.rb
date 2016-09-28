begin
  require 'net/ping/external'
rescue LoadError => e
  puts "Please install net-ping gem: gem install net-ping".
  raise
end

require 'outpost/expectations'

module Outpost
  module Scouts
    # Uses system's "ping" command line tool to check if the server is
    # responding in a timely manner.
    #
    # * Responds to response_time expectation
    #   ({Outpost::Expectations::ResponseTime})
    #
    # It needs the 'net-ping' gem.
    class Ping < Outpost::Scout
      extend Outpost::Expectations::ResponseTime
      attr_reader :response_time
      report_data :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :host The host that will be "pinged".
      # @option options [Object] :pinger An object that can ping hosts.
      # @option options [Integer] :count Count of ping attempts.
      # @option options [Integer] :interval Interval (in sec) between ping attempts.
      # @option options [Integer] :timeout Timeout (in sec) for waiting response.
      #   Defaults to Net::Ping::External.new
      def setup(options)
        @host     = options[:host]
        @pinger   = options[:pinger] || Net::Ping::External.new
        @count    = options[:count] || 1
        @interval = options[:interval] || 1
        @timeout  = options[:timeout] || 5
      end

      # Runs the scout, pinging the host and getting the duration.
      def execute
        if @pinger.is_a?(Net::Ping::External)
          if @pinger.ping(@host, @count, @interval, @timeout)
            # Miliseconds
            @response_time = @pinger.duration * 1000
          end
        else
          # another pinger. Just pass @host
          if @pinger.ping(@host)
            # Miliseconds
            @response_time = @pinger.duration * 1000
          end
        end
      end
    end
  end
end
