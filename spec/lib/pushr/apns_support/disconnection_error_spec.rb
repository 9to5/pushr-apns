require 'spec_helper'
require 'pushr/daemon'
require 'pushr/daemon/apns'
require 'pushr/daemon/apns_support/disconnection_error'

describe Pushr::Daemon::ApnsSupport::DisconnectionError do
  let(:error) { Pushr::Daemon::ApnsSupport::DisconnectionError.new }

  it 'returns a nil error code' do
    expect(error.code).to be_nil
  end

  it 'contains an error description' do
    expect(error.description).not_to be_nil
  end

  it 'returns a message' do
    expect(error.message).not_to be_nil
    expect(error.to_s).not_to be_nil
  end
end
