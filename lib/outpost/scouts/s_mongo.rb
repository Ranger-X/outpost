require 'mongo'
require 'outpost/expectations'

module Outpost
  module Scouts
    # Check Mongo database
    #
    class SMongo < Outpost::Scout
      extend Outpost::Expectations::ResponseCode
      extend Outpost::Expectations::ResponseBody
      extend Outpost::Expectations::ResponseTime

      attr_reader :response_code, :response_body, :response_time
      report_data :response_code, :response_body, :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :url The connection string for mongo.
      def setup(options)
        @url  = options[:url]
      end

      # Runs the scout, connecting to the host and getting the response code,
      # body and time.
      def execute
        previous_time = Time.now
        client = Mongo::Client.new(@url)
        @response_body = client.database.collection_names.join(' ')

        @response_time = (Time.now - previous_time) * 1000 # Miliseconds
        @response_code = 1
      rescue Exception => e
        @response_code = @response_time = nil
        @response_body = e.message
      end
    end
  end
end
