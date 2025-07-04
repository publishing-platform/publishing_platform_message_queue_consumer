module PublishingPlatformMessageQueueConsumer
  class Consumer
    # Create a new consumer
    #
    # @param queue_name [String] Your queue name. This is specific to your application,
    #                            and should already exist and have a binding
    #                            configured via Terraform.
    # @param processor [Object] An object that responds to `process`
    # @param rabbitmq_connection [Object] A Bunny connection object derived from `Bunny.new`
    # @param logger [Object] A Logger object for emitting errors (to stderr by default)
    # @param worker_threads [Number] Size of the worker thread pool. Defaults to 1.
    # @param prefetch [Number] Maximum number of unacked messages to allow on
    #                          the channel. See
    #                          https://www.rabbitmq.com/docs/consumer-prefetch
    #                          Defaults to 1.
    def initialize(queue_name:, processor:, rabbitmq_connection: Bunny.new, logger: Logger.new($stderr), worker_threads: 1, prefetch: 1)
      @queue_name = queue_name
      @processor = processor
      @rabbitmq_connection = rabbitmq_connection
      @logger = logger
      @worker_threads = worker_threads
      @prefetch = prefetch
    end

    def run(subscribe_opts: {})
      @rabbitmq_connection.start

      subscribe_opts = { block: true, manual_ack: true }.merge(subscribe_opts)
      queue.subscribe(subscribe_opts) do |delivery_info, headers, payload|
        message = Message.new(payload, headers, delivery_info)
        message_consumer.process(message)
      rescue StandardError => e
        PublishingPlatformError.notify(e) if defined?(PublishingPlatformError)
        @logger.error "Uncaught exception in processor: \n\n #{e.class}: #{e.message}\n\n#{e.backtrace.join("\n")}"
        exit(1) # Ensure rabbitmq requeues outstanding messages
      end
    rescue SignalException => e
      PublishingPlatformError.notify(e) if defined?(PublishingPlatformError) && e.message != "SIGTERM"

      exit
    end

  private

    def message_consumer
      @message_consumer ||= MessageConsumer.new(
        processors: [
          HeartbeatProcessor.new,
          JSONProcessor.new,
          @processor,
        ],
      )
    end

    def queue
      @queue ||= begin
        channel.prefetch(@prefetch)
        channel.queue(@queue_name, no_declare: true)
      end
    end

    def channel
      @channel ||= @rabbitmq_connection.create_channel(nil, @worker_threads)
    end
  end
end
