require 'spec_helper'
require 'pushr/feedback_apns'

describe Pushr::FeedbackApns do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'create' do
    it 'should create a feedback' do
      feedback = Pushr::FeedbackApns.new(app: 'app_name', device: 'a' * 64, follow_up: 'delete', failed_at: Time.now)
      expect(feedback.app).to eql('app_name')
    end
  end

  describe 'save' do
    let!(:feedback) { Pushr::FeedbackApns.create(app: 'app_name', device: 'a' * 64, follow_up: 'delete', failed_at: Time.now) }
    it 'should save a feedback' do
      expect(Pushr::Feedback.next.class).to eql(Pushr::FeedbackApns)
    end
  end
end
