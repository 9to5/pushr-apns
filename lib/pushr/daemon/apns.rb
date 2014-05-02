module Pushr
  module Daemon
    class Apns
      attr_accessor :configuration

      def initialize(options)
        self.configuration = options

        @feedback_receiver = ApnsSupport::FeedbackReceiver.new(configuration)
        start_feedback
      end

      def connectiontype
        ApnsSupport::ConnectionApns
      end

      def start_feedback
        @feedback_receiver.start
      end

      def stop_feedback
        @feedback_receiver.stop
      end

      def stop
        stop_feedback
      end
    end
  end
end
