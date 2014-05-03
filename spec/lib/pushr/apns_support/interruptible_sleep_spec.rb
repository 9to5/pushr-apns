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
    subject
  end

  it 'selects on the reader' do
    allow(IO).to receive(:pipe).and_return([rd, wr])
    expect(IO).to receive(:select).with([rd], nil, nil, 1)
    subject.sleep(1)
  end

  it 'closes the writer' do
    allow(IO).to receive(:pipe).and_return([rd, wr])
    expect(rd).to receive(:close)
    expect(wr).to receive(:close)
    subject.close
  end

  it 'returns false when timeout occurs' do
    expect(subject.sleep(0.01)).to eql false
  end

  it 'returns true when sleep does not timeout' do
    subject.interrupt_sleep
    expect(subject.sleep(0.01)).to eql true
  end
end
