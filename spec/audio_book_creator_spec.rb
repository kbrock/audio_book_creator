require 'spec_helper'

describe AudioBookCreator do
  subject { described_class }
  it 'should have a version number' do
    expect(AudioBookCreator::VERSION).not_to be_nil
  end

  context ".should_write" do
    it "should know file does not exist" do
      expect(File).to receive(:exist?).with("x").and_return(false)
      expect(subject.should_write?("x", false)).to be_truthy
    end

    it "should respect force" do
      expect(File).not_to receive(:exist?)
      expect(subject.should_write?("x", true)).to be_truthy
    end

    it "should know file exists" do
      expect(File).to receive(:exist?).with("x").and_return(true)
      expect(subject.should_write?("x", false)).not_to be_truthy
    end
  end

  context ".logger=" do
    let(:log) { double("logger") }
    it "sets logger" do
      subject.logger=log
      expect(subject.logger).to eq(log)
      subject.logger=nil
    end
  end

  context ".logger" do
    before { subject.logger=nil }

    it "logs to stdout" do
      expect(STDOUT).to receive(:write).with(/logging message/)
      subject.logger.error "logging message"
    end

    it "defaults to warning" do
      # clear out the cache up front
      expect(subject.logger.level).to eq(Logger::WARN)
    end
  end
end
