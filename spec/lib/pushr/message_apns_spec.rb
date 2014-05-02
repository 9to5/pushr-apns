require 'spec_helper'
require 'pushr/apns/binary_notification_validator'
require 'pushr/message_apns'

describe Pushr::MessageApns do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'next' do
    it 'returns next message' do
      expect(Pushr::Message.next('pushr:app_name:apns')).to eql(nil)
    end
  end

  describe 'save' do
    let(:message) do
      hsh = { app: 'app_name', device: 'a' * 64,  alert: 'message',
              badge: 1, sound: '1.aiff', expiry: 24 * 60 * 60, attributes_for_device: { key: 'test' } }
      Pushr::MessageApns.new(hsh)
    end

    it 'should return true' do
      expect(message.save).to eql true
    end
    it 'should save a message' do
      message.save
      expect(Pushr::Message.next('pushr:app_name:apns')).to be_kind_of(Pushr::MessageApns)
    end
    it 'should respond to to_message' do
      expect(message.to_message).to be_kind_of(String)
    end
  end
end
