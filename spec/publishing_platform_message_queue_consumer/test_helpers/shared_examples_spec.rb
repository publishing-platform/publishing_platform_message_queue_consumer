require "spec_helper"

RSpec.describe "The usage of the shared example" do
  subject do
    klass = Class.new do
      def process(_message); end
    end

    klass.new
  end

  it_behaves_like "a message queue processor"
end
