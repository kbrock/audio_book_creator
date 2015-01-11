require "spec_helper"

describe AudioBookCreator::SpokenChapter do
  subject { described_class.new("title", "filename") }

  it { expect(subject.title).to eq("title") }
  it { expect(subject.filename).to eq("filename") }

  context "#eql" do
    it "should understand ==" do
      expect(subject).to eq(described_class.new("title", "filename"))
    end

    it "should understand != nil" do
      expect(subject).not_to eq(nil)
    end

    it "should understand != different class" do
      expect(subject).not_to eq("abc")
    end

    it "should understand != title" do
      expect(subject).not_to eq(described_class.new("title2", "filename"))
    end

    it "should understand != filename" do
      expect(subject).not_to eq(described_class.new("title", "filename2"))
    end
  end
end
