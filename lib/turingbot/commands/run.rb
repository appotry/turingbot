require 'eval_in'

module Turingbot
  module Commands
    class Run < Command
      match /^run/

      def run
        if m = argument.match(%r!https://gist\.github\.com/(.*)!)
          r = Faraday.get "https://gist.githubusercontent.com/#{m[1]}/raw"
          code = r.body
        else
          code = argument
        end

        puts "Running: #{code}"

        result = EvalIn.call(code, stdin: 'world', language: 'ruby/mri-2.1')

        say "=> #{result.output}"
      end
    end
  end
end
