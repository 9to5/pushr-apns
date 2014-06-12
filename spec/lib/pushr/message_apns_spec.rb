require 'spec_helper'
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
      hsh = { app: 'app_name', device: 'a' * 64, alert: 'message', badge: 1, sound: '1.aiff',
              expiry: 24 * 60 * 60, attributes_for_device: { key: 'test' }, priority: 10 }
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

    context 'content-available: 1' do
      context 'with no alert/badge/sound' do
        let(:message) do
          hsh = { app: 'app_name', device: 'a' * 64, expiry: 24 * 60 * 60, priority: priority, content_available: 1 }
          Pushr::MessageApns.new(hsh)
        end

        context 'with priority 5' do
          let(:priority) { 5 }
          it 'should have priority 5' do
            expect(message.save).to eql true
          end
        end

        context 'with priority 10' do
          let(:priority) { 10 }
          it 'should be invalid if priority 10' do
            expect(message.save).to eql false
          end
        end
      end

      context 'with alert/badge/sound' do
        let(:message) do
          hsh = { app: 'app_name', alert: 'test', device: 'a' * 64, expiry: 24 * 60 * 60, priority: priority, content_available: 1 }
          Pushr::MessageApns.new(hsh)
        end

        context 'with priority 5' do
          let(:priority) { 5 }
          it 'should have priority 5' do
            expect(message.save).to eql true
          end
        end

        context 'with priority 10' do
          let(:priority) { 10 }
          it 'should be valid if priority 10' do
            expect(message.save).to eql true
          end
        end
      end
    end
  end
end
