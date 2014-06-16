require 'spec_helper'
require 'pushr/configuration_apns'

describe Pushr::ConfigurationApns do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'all' do
    it 'returns all configurations' do
      expect(Pushr::Configuration.all).to eql([])
    end
  end

  describe 'create' do
    it 'should create a configuration' do
      config = Pushr::ConfigurationApns.new(app: 'app_name', connections: 2, enabled: true, certificate: 'BEGIN CERTIFICATE',
                                            certificate_password: nil, sandbox: true, skip_check_for_error: true)
      expect(config.key).to eql('app_name:apns')
    end
  end

  describe 'save' do
    let(:config) do
      Pushr::ConfigurationApns.new(app: 'app_name', connections: 2, enabled: true, certificate: 'BEGIN CERTIFICATE',
                                   certificate_password: nil, sandbox: true, skip_check_for_error: true)
    end
    it 'should save a configuration' do
      config.save
      expect(Pushr::Configuration.all.count).to eql(1)
      expect(Pushr::Configuration.all[0].class).to eql(Pushr::ConfigurationApns)
    end
  end
end
