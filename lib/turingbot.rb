require "turingbot/version"

require "rack/request"

require "json"

require "faraday"

require "turingbot/command"

module Turingbot
  class Bot

    def initialize(name="turingbot", channel=nil)
      @addressed = %r!@#{name}:|@#{name}|#{name}:|\.\s!
    end

    def call(env)
      req = Rack::Request.new(env)

      if req.post?
        params = req.params

        if !channel || params["channel_name"] == channel
          process_message(params)
        end
      end

      [200, {}, [""]]
    end

    def process_message(vars)
      text = vars["text"]

      if m = text.match(@addressed)
        vars["text"] = m.post_match.strip

        begin
          Command.run(vars)
        rescue Exception => e
          vars["error"] = e
          Commands::Error.new(vars, nil, nil).run
        end
      end
    end

    def basic_process_message(vars)
      from = vars["user_name"]
      text = vars["text"]
      channel = vars["channel_id"]
      token = vars["token"]

      if text.match(/^hello/i)
        say token, channel, "hello #{from}"
      end
    end

    URL = "https://turingschool.slack.com/services/hooks/hubot"

    def say(token, channel, what)
      url = URL + "?token=#{token}"
      body = {
        "username" => "turingbot",
        "channel" => channel,
        "text" => what,
      }

      data = JSON.generate(body)

      conn = Faraday.new(:url => 'https://turingschool.slack.com') do |faraday|
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
     
      conn.post do |req|
        req.url "/services/hooks/hubot?token=#{token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = data
      end
    end
  end
end
