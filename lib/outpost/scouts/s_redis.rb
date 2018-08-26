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
      # @option options [String] :url The connection url in form 'redis://:p4ssw0rd@10.0.1.1:6380/15'
      # @option options [String] :host The host that will be connected to.
      # @option options [Number] :port The port that will be used to.
      # @option options [Number] :db The database.
      # @option options [String] :password Auth password for database.
      # @option options [Integer] :timeout The connection timeout.
      def setup(options)
        @url      = options[:url]
        @host     = options[:host]
        @port     = options[:port] || 6379
        @db       = options[:db] || 1
        @password = options[:password]
        @timeout  = options[:timeout] || 1
      end

      # Runs the scout, connecting to the host and getting the response code,
      # body and time.
      def execute
        previous_time = Time.now

        connection_string = @url.nil? ? {:host => @host, :port => @port, :db => @db, :timeout => @timeout.to_i, :password => @password } : { :url => @url, :timeout => @timeout.to_i }

        redis = Redis.new(**connection_string)
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
