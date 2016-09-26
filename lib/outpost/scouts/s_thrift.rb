require 'outpost/thrift/extractor'
require 'outpost/expectations'

module Outpost
  module Scouts
    # Check Thrift
    #
    class SThrift < Outpost::Scout
      extend Outpost::Expectations::ResponseCode
      extend Outpost::Expectations::ResponseBody
      extend Outpost::Expectations::ResponseTime

      attr_reader :response_code, :response_body, :response_time
      report_data :response_code, :response_body, :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :host The host that will be connected to.
      # @option options [Number] :port The port that will be used to.
      def setup(options)
        @host = options[:host]
        @port = options[:port] || 9091
        #@db   = options[:db] || 1
      end

      # Runs the scout, connecting to the host and getting the response code,
      # body and time.
      def execute
        previous_time = Time.now

        transport = Thrift::BufferedTransport.new(Thrift::Socket.new(@host, @port))
        protocol = Thrift::BinaryProtocol.new(transport)

        client = Extractor::Client.new(protocol)

        transport.open()
        client.normalizeKeyword('test')
        transport.close()

        @response_time = (Time.now - previous_time) * 1000 # Miliseconds
        @response_code = 1
      rescue Exception => e
        @response_code = @response_time = nil
        @response_body = e.message
      end
    end
  end
end
