require 'spec_helper'

describe AudioBookCreator do
  subject { described_class }
  it 'should have a version number' do
    expect(AudioBookCreator::VERSION).not_to be_nil
  end

  context ".sanitize_filename" do
    it "should join strings" do
      expect(subject.sanitize_filename("title", "jpg")).to eq("title.jpg")
    end

    it "should handle arrays" do
      expect(subject.sanitize_filename(%w(title jpg))).to eq("title.jpg")
    end

    it "should ignore nils" do
      expect(subject.sanitize_filename("title", nil)).to eq("title")
    end

    it "should support titles with spaces" do
      expect(subject.sanitize_filename("title !for")).to eq("title-for")
    end

    it "should support titles with extra stuff" do
      expect(subject.sanitize_filename("title,for!")).to eq("title-for")
    end
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

    it "should assume force is false" do
      expect(File).to receive(:exist?).with("x").and_return(true)
      expect(subject.should_write?("x")).not_to be_truthy
    end
  end
end
