module Pushr
  class ConfigurationApns < Pushr::Configuration
    attr_reader :certificate
    attr_accessor :certificate_password, :sandbox, :skip_check_for_error
    validates :certificate, presence: true
    validates :sandbox, inclusion: { in: [true, false] }
    validates :skip_check_for_error, inclusion: { in: [true, false] }, allow_blank: true

    def name
      :apns
    end

    def certificate=(value)
      if /BEGIN CERTIFICATE/.match(value)
        @certificate = value
      else
        # assume it's the path to the certificate and try to read it:
        @certificate = read_file(value)
      end
    end

    def to_hash
      { type: self.class.to_s, app: app, enabled: enabled, connections: connections, certificate: certificate,
        certificate_password: certificate_password, sandbox: sandbox, skip_check_for_error: skip_check_for_error }
    end

    private

    # if filename is something wacky, this will break and raise an exception - that's OK
    def read_file(filename)
      File.read(build_filename(filename))
    end

    def build_filename(filename)
      if Pathname.new(filename).absolute?
        filename
      elsif Pushr::Core.configuration_file
        File.join(File.dirname(Pushr::Core.configuration_file), filename)
      else
        File.join(Dir.pwd, filename)
      end
    end
  end
end
