# frozen_string_literal: true

require_relative "lib/publishing_platform_message_queue_consumer/version"

Gem::Specification.new do |spec|
  spec.name = "publishing_platform_message_queue_consumer"
  spec.version = PublishingPlatformMessageQueueConsumer::VERSION
  spec.authors = ["Publishing Platform"]

  spec.summary = "AMQP message queue consumption with Publishing Platform conventions"
  spec.description = "Avoid writing boilerplate code in order to consume messages from an AMQP message queue. Plug in queue configuration, and how to process each message."

  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir.glob("lib/**/*") + %w[LICENSE README.md]
  spec.require_paths = %w[lib]

  spec.add_dependency "bunny", "~> 2.24"

  spec.add_development_dependency "publishing_platform_rubocop"
  spec.add_development_dependency "simplecov"
end
