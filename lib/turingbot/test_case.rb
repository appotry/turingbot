require 'minitest/autorun'
require 'turingbot/command'

module Turingbot
  class TestCase < Minitest::Test
    class Response
      def post(body, token)
        @body = body
        @token = token
      end

      attr_reader :body
    end

    def run_command(msg, opts={})
      response = Response.new
      Turingbot::Command.run(params_for(msg, opts), response)
      response
    end

    def params_for(msg, opts={})
      { "text"         => msg,
        "user_name"    => opts.fetch(:from, "tester"),
        "channel_name" => opts.fetch(:channel, "test"),
        "channel_id"   => "aabbcc",
        "token"        => "xxyyzz"
      }
    end
  end
end
