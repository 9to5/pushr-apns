require 'spec_helper'
require 'pushr/daemon'
require 'pushr/daemon/apns'
require 'pushr/daemon/apns_support/interruptible_sleep'

describe Pushr::Daemon::ApnsSupport::InterruptibleSleep do
  let(:rd) { double(close: nil) }
  let(:wr) { double(close: nil) }

  subject { Pushr::Daemon::ApnsSupport::InterruptibleSleep.new }

  it 'creates a new pipe' do
    expect(IO).to receive(:pipe).and_return([rd, wr])
    allow(IO).to receive(:select).with([rd], nil, nil, 1)
    subject.sleep(1)
  end

  it 'selects on the reader' do
    allow(IO).to receive(:pipe).and_return([rd, wr])
    expect(IO).to receive(:select).with([rd], nil, nil, 1)
    subject.sleep(1)
  end

  it 'closes the writer' do
    allow(IO).to receive(:pipe).and_return([rd, wr])
    allow(IO).to receive(:select).with([rd], nil, nil, 1)
    expect(wr).to receive(:close)
    subject.sleep(1)
    subject.interrupt
  end
end
