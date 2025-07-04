module PublishingPlatformMessageQueueConsumer
  class MessageConsumer
    def initialize(processors:)
      @processors = processors
    end

    def process(message)
      @processors.each do |processor|
        break unless processor.process(message)
      end
    end
  end
end
