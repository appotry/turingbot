require 'shikashi'

module Turingbot
  module Commands
    class Run < Command
      match /^run/

      Privileges = Shikashi::Privileges.new.tap do |priv|
        priv.methods_of(Fixnum).allow_all
        priv.methods_of(Hash).allow_all
        priv.methods_of(Array).allow_all
        priv.methods_of(Class).allow :new
        priv.methods_of(Module).allow :new
      end

      def run
        if m = argument.match(%r!https://gist\.github\.com/(.*)!)
          r = Faraday.get "https://gist.githubusercontent.com/#{m[1]}/raw"
          code = r.body
        else
          code = argument
        end

        puts "Running: #{code}"

        s = Shikashi::Sandbox.new

        val = s.run(Privileges, code)
        say "=> #{val}"
      end
    end
  end
end
