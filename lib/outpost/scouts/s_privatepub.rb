require "digest/sha1"
require "net/http"
require "net/https"
require 'outpost/expectations'

module Outpost
  module Scouts
    # Check PrivatePub (websockets) connection
    #
    class SPrivatepub < Outpost::Scout
      extend Outpost::Expectations::ResponseCode
      extend Outpost::Expectations::ResponseBody
      extend Outpost::Expectations::ResponseTime

      attr_reader :response_code, :response_body, :response_time
      report_data :response_code, :response_body, :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :server The Faye server connection string.
      # @option options [String] :token The secret token of the server.
      # @option options [String] :channel The channel to publish on.
      # @option options [String] :data The data, which will be sended on each check to the channel.
      def setup(options)
        @server   = options[:server]
        @token    = options[:token]
        @channel  = options[:channel]
        @data     = options[:data]
      end

      # Runs the scout, connecting to the host and getting the response code,
      # body and time.
      def execute
        previous_time = Time.now

        publish_message(message(@channel, @data))

        @response_time = (Time.now - previous_time) * 1000 # Miliseconds
        @response_code = 1
      rescue Exception => e
        @response_code = @response_time = nil
        @response_body = e.message
      end

      private

      # These functions extracted from PrivatePub gem (https://github.com/ryanb/private_pub/blob/7ad77617b1f48980d6f114bc96018f2964a07bdc/lib/private_pub.rb)

      # Returns a message hash for sending to Faye
      def message(channel, data)
        message = {:channel => channel, :data => {:channel => channel}, :ext => {:private_pub_token => @token}}
        if data.kind_of? String
          message[:data][:eval] = data
        else
          message[:data][:data] = data
        end
        message
      end

      # Sends the given message hash to the Faye server using Net::HTTP.
      def publish_message(message)
        raise Error, "No server specified." unless @server
        url = URI.parse(@server)

        form = Net::HTTP::Post.new(url.path.empty? ? '/' : url.path)
        form.set_form_data(:message => message.to_json)

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = url.scheme == "https"
        http.start {|h| h.request(form)}
      end
    end
  end
end
