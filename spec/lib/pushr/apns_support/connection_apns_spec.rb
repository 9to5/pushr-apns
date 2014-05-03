require 'spec_helper'
require 'pushr/configuration_apns'
require 'pushr/message_apns'
require 'pushr/daemon'
require 'pushr/daemon/apns'
require 'pushr/daemon/apns_support/connection_apns'

describe Pushr::Daemon::ApnsSupport::ConnectionApns do
  pending 'add test'

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end

    logger = double('logger')
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
    allow(logger).to receive(:warn)
    Pushr::Daemon.logger = logger

    allow(TCPSocket).to receive(:new).and_return(tcpsocket)
    allow(OpenSSL::SSL::SSLSocket).to receive(:new).and_return(sslsocket)
  end

  let(:tcpsocket) { double('TCPSocket').as_null_object }
  let(:sslsocket) { double('SSLSocket').as_null_object }
  let(:certificate) { File.read(File.join(File.dirname(__FILE__), '..', '..', '..', 'support', 'cert_without_password.pem')) }
  let(:config) do
    Pushr::ConfigurationApns.new(app: 'app_name', connections: 2, enabled: true, certificate: certificate)
  end
  let(:message) do
    hsh = { app: 'app_name', device: 'a' * 64,  alert: 'message',
            badge: 1, sound: '1.aiff', expiry: 24 * 60 * 60, attributes_for_device: { key: 'test' } }
    Pushr::MessageApns.new(hsh)
  end
  let(:connection) { Pushr::Daemon::ApnsSupport::ConnectionApns.new(config, 1) }

  describe 'sends a message' do
    it 'succesful' do
      expect(sslsocket).to receive(:write).with(message.to_message)
      connection.connect
      connection.write(message)
    end
  end
end
