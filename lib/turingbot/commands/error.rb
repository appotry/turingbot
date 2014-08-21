module Turingbot
  module Commands
    class Error < Command
      def run
        say "Sorry, an error occured: #{@vars['error']}"
      end
    end
  end
end
