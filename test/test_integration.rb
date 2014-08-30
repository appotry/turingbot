require 'turingbot'
require 'turingbot/test_case'
require "rack/test"
require 'webmock'
WebMock.disable_net_connect! # redundant, but I prefer the explicitness

class TestIntegration < Turingbot::TestCase
  BOT_NAME     = 'bot-name'
  CHANNEL_NAME = 'channel-name'

  class Slack
    include Rack::Test::Methods
    def app
      Turingbot::Bot.new(BOT_NAME, CHANNEL_NAME)
    end
  end

  def slack
    @slack ||= Slack.new
  end

  include WebMock::API

  def teardown
    WebMock.reset!
  end

  def assert_no_requests_made
    assert_predicate WebMock::RequestRegistry.instance.requested_signatures.hash, :empty? # O.o
  end

  def test_it_posts_command_responses_to_slack
    capture_io do # <-- TODO should be a better way than this (ie inject logger)
      stub_request(:post, "https://turingschool.slack.com/services/hooks/hubot?token=xxyyzz")
        .with(body: JSON.dump("username" => "turingbot", "channel" => "aabbcc", "text" => "back attacha' Jeff"))
        .to_return(status: 200)
      response = slack.post '/', params_for("#{BOT_NAME} hello there", from: "Jeff", channel: CHANNEL_NAME)
      assert_predicate response, :ok?
    end
  end

  def test_it_only_responds_to_post_requests
    response = slack.get '/', params_for("#{BOT_NAME} hello there", from: "Jeff", channel: CHANNEL_NAME)
    assert_predicate response, :ok?
    assert_no_requests_made
  end
end
