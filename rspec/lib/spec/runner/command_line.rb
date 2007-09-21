require 'spec/runner/option_parser'

module Spec
  module Runner
    # Facade to run specs without having to fork a new ruby process (using `spec ...`)
    class CommandLine
      # Runs specs. +argv+ is the commandline args as per the spec commandline API, +err+ 
      # and +out+ are the streams output will be written to. +exit+ tells whether or
      # not a system exit should be called after the specs are run and
      # +warn_if_no_files+ tells whether or not a warning (the help message)
      # should be printed to +err+ in case no files are specified.
      def self.run(argv, err, out, exit=true, warn_if_no_files=true)
        old_behaviour_runner = defined?($behaviour_runner) ? $behaviour_runner : nil
        begin
          parser = OptionParser.new(err, out, warn_if_no_files)
          paths = []
          options = parser.order!(argv) do |path|
            paths << path
          end
          $behaviour_runner = options.create_behaviour_runner
          return unless $behaviour_runner # This is the case if we use --drb

          $behaviour_runner.run(paths, exit)
        ensure
          $behaviour_runner = old_behaviour_runner
        end
      end
    end
  end
end
