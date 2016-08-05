require 'redis'
require 'outpost/expectations'

module Outpost
  module Scouts
    # Check Redis database
    #
    class SRedis < Outpost::Scout
      extend Outpost::Expectations::ResponseCode
      extend Outpost::Expectations::ResponseBody
      extend Outpost::Expectations::ResponseTime

      attr_reader :response_code, :response_body, :response_time
      report_data :response_code, :response_body, :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :host The host that will be connected to.
      # @option options [Number] :port The port that will be used to.
      # @option options [Number] :db The database.
      def setup(options)
        @host = options[:host]
        @port = options[:port] || 6379
        @db   = options[:db] || 1
      end

      # Runs the scout, connecting to the host and getting the response code,
      # body and time.
      def execute
        previous_time = Time.now
        redis = Redis.new(:host => @host, :port => @port, :db => @db, :timeout => 1)
        redis.ping
        @response_time = (Time.now - previous_time) * 1000 # Miliseconds
        @response_code = 1
      rescue Exception => e
        @response_code = @response_time = nil
        @response_body = e.message
      end
    end
  end
end
