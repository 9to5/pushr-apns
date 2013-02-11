module Pushr
  class ConfigurationApns < Pushr::Configuration
    attr_accessor :gem, :type, :app, :enabled, :connections, :certificate, :certificate_password, :sandbox, :feedback_poll, :skip_check_for_error
    validates :certificate, :presence => true
    validates :sandbox, :inclusion => { :in => [true, false] }
    validates :feedback_poll, :presence => true
    validates :skip_check_for_error, :inclusion => { :in => [true, false] }, :allow_blank => true

    def name
      :apns
    end

    def to_json
      ::MultiJson.dump({gem: 'pushr-apns', type: self.class.to_s, app: @app, enabled: @enabled, connections: @connections, certificate: @certificate, certificate_password: @certificate_password, sandbox: @sandbox, feedback_poll: @feedback_poll, skip_check_for_error: @skip_check_for_error})
    end
  end
end