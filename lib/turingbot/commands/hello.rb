module Turingbot
  module Commands
    class Hello < Command
      match /^hello/

      def run
        say "back attacha' #{sender}"
      end
    end
  end
end
