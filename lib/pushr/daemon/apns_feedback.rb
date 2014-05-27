module Pushr
  module Daemon
    class ApnsFeedback
      attr_accessor :configuration, :handlers

      def initialize(options)
        @configuration = options
        @handlers = []
      end

      def start
        configuration.connections.times do |i|
          connection = ApnsSupport::FeedbackReceiver.new(configuration, i + 1)
          connection.start
          @handlers << connection
        end
      end

      def stop
        @handlers.map(&:stop)
      end
    end
  end
end
