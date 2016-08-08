begin
  require 'kafka'
rescue LoadError => e
  puts "Please install ruby-kafka gem: gem install ruby-kafka".
  raise
end

require 'outpost/expectations'

module Outpost
  module Scouts
    # Check Kafka
    #
    class SKafka < Outpost::Scout
      extend Outpost::Expectations::ResponseCode
      extend Outpost::Expectations::ResponseBody
      extend Outpost::Expectations::ResponseTime

      attr_reader :response_code, :response_body, :response_time
      report_data :response_code, :response_body, :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [Array]  :brokers Brokers list.
      # @option options [String] :topic The topic to which produce test message. Default: 'Test topic'
      # @option options [String] :message The test message. Default: 'Test message'
      def setup(options)
        @brokers  = options[:brokers] || []
        @topic    = options[:topic] || 'Test topic'
        @message  = options[:message] || 'Test message'
      end

      # Runs the scout, connecting to the host and getting the response code,
      # body and time.
      def execute
        previous_time = Time.now
        kafka = Kafka.new(
            # At least one of these nodes must be available:
            seed_brokers: @brokers,
            # Set an optional client id in order to identify the client to Kafka:
            client_id: 'outpost-monitor',
            connect_timeout: 2,
        )

        kafka.deliver_message(@message, topic: @topic)

        @response_time = (Time.now - previous_time) * 1000 # Miliseconds
        @response_code = 1
      rescue Exception => e
        @response_code = @response_time = nil
        @response_body = "Kafka exception: #{e.message}"
      end
    end
  end
end
