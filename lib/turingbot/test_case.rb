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
      vars = {
        "text"         => msg,
        "user_name"    => opts.fetch(:from, "tester"),
        "channel_name" => opts.fetch(:channel, "test"),
        "channel_id"   => "aabbcc",
        "token"        => "xxyyzz"
      }

      response = Response.new

      Turingbot::Command.run(vars, response)

      response
    end
  end
end
