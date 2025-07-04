module PublishingPlatformMessageQueueConsumer
  class JSONProcessor
    JSON_FORMAT = "application/json".freeze

    def process(message)
      if message.headers.content_type == JSON_FORMAT
        message.payload = JSON.parse(message.payload)
      end

      true
    rescue JSON::ParserError => e
      PublishingPlatformError.notify(e) if defined?(PublishingPlatformError)
      message.discard
      false
    end
  end
end
