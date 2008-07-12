require 'stringio'

dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
$_spec_spec = true # Prevents Kernel.exit in various places

require 'spec'
require 'spec/mocks'
require 'spec/story'
spec_classes_path = File.expand_path("#{dir}/../spec/spec/spec_classes")
require spec_classes_path unless $LOAD_PATH.include?(spec_classes_path)
require File.dirname(__FILE__) + '/../lib/spec/expectations/differs/default'

module Spec
  module Matchers
    def fail
      raise_error(Spec::Expectations::ExpectationNotMetError)
    end

    def fail_with(message)
      raise_error(Spec::Expectations::ExpectationNotMetError, message)
    end
  end
end

class NonStandardError < Exception; end

def exception_from(&block)
  exception = nil
  begin
    yield
  rescue StandardError => e
    exception = e
  end
  exception
end

share_as :SandboxedOptions do
  attr_reader :options

  before(:each) do
    @original_rspec_options = ::Spec::Runner.options
    ::Spec::Runner.options = @options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new)
  end

  after(:each) do
    ::Spec::Runner.options = @original_rspec_options
  end

  def run_with(options)
    ::Spec::Runner.options = options
    ::Spec::Runner::CommandLine.run(options)
  end
end unless Object.const_defined?(:SandboxedOptions)

module Spec
  module Runner
    class << self
      attr_writer :options
    end
  end
end
