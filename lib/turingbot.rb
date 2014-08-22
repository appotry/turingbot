require "turingbot/version"

require "rack/request"

require "json"

require "faraday"

require "turingbot/command"

module Turingbot
  class Bot

    def initialize(name="turingbot", channel=nil)
      @addressed = %r!^(@#{name}:|@#{name}\s|#{name}:|#{name}\s|\.\s)!
      @channel = channel
    end

    def call(env)
      req = Rack::Request.new(env)

      if req.post?
        params = req.params

        if !@channel || params["channel_name"] == @channel
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
  end
end
