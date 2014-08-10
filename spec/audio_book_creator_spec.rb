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
end
