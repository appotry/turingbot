module Turingbot
  class Command

    Commands = []

    def self.match(prefix, kind=nil)
      Commands << [prefix, kind, self]
    end

    def self.run(vars)
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
        cmd.new(vars, kind, match).run
      end
    end

    def initialize(vars, kind, match)
      @vars = vars
      @kind = kind
      @match = match
    end

    attr_reader :vars, :kind, :match

    URL = "https://turingschool.slack.com"
    PATH = "/services/hooks/hubot"

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

      data = JSON.generate(body)

      conn = Faraday.new(:url => URL) do |faraday|
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
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
