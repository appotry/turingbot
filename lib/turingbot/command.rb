module Turingbot
  class Command

    Commands = []

    def self.match(prefix, kind=nil)
      Commands << [prefix, kind, self]
    end

    def self.run(vars, actions)
      text = vars["text"]

      kind = nil
      cmd = nil
      match = nil

      Commands.each do |prefix,k,klass|
        if m = text.match(prefix)
          cmd = klass
          match = m
          kind = k
          break
        end
      end

      if cmd
        cmd.new(vars, actions, kind, match).run
      end
    end

    def initialize(vars, actions, kind, match)
      @vars = vars
      @actions = actions
      @kind = kind
      @match = match
    end

    attr_reader :vars, :kind, :match

    def sender
      @vars["user_name"]
    end

    def channel
      @vars["channel_name"]
    end

    def argument
      @match.post_match.strip
    end

    def say(what)
      token = @vars["token"]
      channel = @vars["channel_id"]

      body = {
        "username" => "turingbot",
        "channel" => channel,
        "text" => what,
      }

      @actions.post body, token
    end

    URL = "https://turingschool.slack.com"
    PATH = "/services/hooks/hubot"

    def self.post(body, token)
      data = JSON.generate(body)

      conn = Faraday.new(:url => URL) do |faraday|
        faraday.response :logger, Logger.new($stdout) # log requests to $stdout
        faraday.adapter  Faraday.default_adapter      # make requests with Net::HTTP
      end

      conn.post do |req|
        req.url "#{PATH}?token=#{token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = data
      end
    end
  end
end

dir = File.expand_path("..", __FILE__)

Dir["#{dir}/commands/*.rb"].sort.each do |i|
  require i
end
