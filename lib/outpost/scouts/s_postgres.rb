begin
  require 'pg'
rescue LoadError => e
  puts "Please install pg gem: gem install pg".
  raise
end

require 'outpost/expectations'

module Outpost
  module Scouts
    # Check PostgreSQL database
    #
    class SPostgres < Outpost::Scout
      extend Outpost::Expectations::ResponseCode
      extend Outpost::Expectations::ResponseBody
      extend Outpost::Expectations::ResponseTime

      attr_reader :response_code, :response_body, :response_time
      report_data :response_code, :response_body, :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :conn_str The connection string for postgres.
      # @option options [String] :sql The SQL query.
      def setup(options)
        @conn_str  = options[:conn_str]
        @sql       = options[:sql] || 'SELECT * FROM pg_stat_activity'
      end

      # Runs the scout, connecting to the host and getting the response code,
      # body and time.
      def execute
        conn = PG::Connection.new(@conn_str)

        previous_time = Time.now
        conn.exec(@sql) do |result|
          @response_body = result.to_s
        end

        @response_time = (Time.now - previous_time) * 1000 # Miliseconds
        @response_code = 1
      rescue Exception => e
        @response_code = @response_time = nil
        @response_body = "Postgres exception: #{e.message}"
      end
    end
  end
end
