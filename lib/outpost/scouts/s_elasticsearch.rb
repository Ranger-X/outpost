begin
  require 'elasticsearch'
rescue LoadError => e
  puts "Please install elasticsearch gem: gem install elasticsearch".
  raise
end

require 'outpost/expectations'

module Outpost
  module Scouts
    # Check ElasticSearch cluster health
    #
    class SElasticsearch < Outpost::Scout
      extend Outpost::Expectations::ResponseCode
      extend Outpost::Expectations::ResponseBody
      extend Outpost::Expectations::ResponseTime

      attr_reader :response_code, :response_body, :response_time
      report_data :response_code, :response_body, :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [Array]  :urls ES cluster endpoint address(es).
      # @option options [Hash]   :transport_options ES transport options (ex: {request_timeout: 5*60, reload_on_failure: true})
      def setup(options)
        @urls              = options[:urls] || []
        @transport_options = options[:transport_options] || {request_timeout: 2 * 60, reload_on_failure: true, log: false }
      end

      # Runs the scout, connecting to the host and getting the response code,
      # body and time.
      def execute
        previous_time = Time.now

        client = Elasticsearch::Client.new urls: @urls.join(','), **@transport_options
        health = client.cluster.health

        @response_time = (Time.now - previous_time) * 1000 # Miliseconds
        @response_body = health.to_json
        @response_code = case health['status'].to_s.downcase
                            when 'green' then 1
                            when 'yellow' then 2
                            when 'red' then 3
                         else
                           0
                         end
      rescue Exception => e
        @response_code = @response_time = nil
        @response_body = "ElasticSearch exception: #{e.message}"
      end
    end
  end
end
