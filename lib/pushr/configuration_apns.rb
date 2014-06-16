module Pushr
  class ConfigurationApns < Pushr::Configuration
    attr_accessor :certificate, :certificate_password, :sandbox, :skip_check_for_error
    validates :certificate, presence: true
    validates :sandbox, inclusion: { in: [true, false] }
    validates :skip_check_for_error, inclusion: { in: [true, false] }, allow_blank: true

    def certificate
      if /BEGIN CERTIFICATE/.match(@certificate)
        @certificate
      else
        # assume it's the path to the certificate and try to read it:
        @certificate = read_file(@certificate)
      end
    end

    def name
      :apns
    end

    def to_hash
      { type: self.class.to_s, app: app, enabled: enabled, connections: connections, certificate: certificate,
        certificate_password: certificate_password, sandbox: sandbox, skip_check_for_error: skip_check_for_error }
    end

    private

    # if filename is something wacky, this will break and raise an exception - that's OK
    def read_file(filename)
      unless Pathname.new(filename).absolute?
        if Pushr::Core.configuration_file
          filename = File.join(File.dirname(Pushr::Core.configuration_file), filename)
        else
          filename = File.join(Dir.pwd, filename)
        end
      end
      File.read(filename)
    end
  end
end
