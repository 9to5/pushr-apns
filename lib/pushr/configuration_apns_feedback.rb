module Pushr
  class ConfigurationApnsFeedback < Pushr::Configuration
    attr_accessor :id, :type, :app, :enabled, :connections, :feedback_poll
    validates :feedback_poll, numericality: true, presence: true

    def name
      :apns_feedback
    end

    def to_json
      hsh = { type: self.class.to_s, app: app, enabled: enabled, connections: connections, feedback_poll: feedback_poll }
      MultiJson.dump(hsh)
    end
  end
end
