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
end
