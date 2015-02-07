require 'spec_helper'

describe AudioBookCreator::BookDef do
  context "with single parameter" do
    subject { described_class.new("dir") }
    it { expect(subject.base_dir).to eq("dir") }
    it { expect(subject.title).to eq("dir") }
    it { expect(subject.author).to eq("Vicki") }
    it { expect(subject.cache_filename).to eq("dir/pages.db") }
  end

  context "with all parameters" do
    subject { described_class.new("the title", "author", "dir", 5, "cachename") }
    it { expect(subject.base_dir).to eq("dir") }
    it { expect(subject.title).to eq("the title") }
    it { expect(subject.author).to eq("author") }
    it { expect(subject.cache_filename).to eq("cachename") }

    it { expect(subject.filename).to eq("the-title.m4b") }
  end

  context "with derived title" do
    subject { described_class.new("the title", "author", nil, nil, "cachename") }
    it { expect(subject.base_dir).to eq("the-title") }
  end

  context "with derived title and max-paragraphs" do
    subject { described_class.new("the title", "author", nil, 5, "cachename") }
    it { expect(subject.base_dir).to eq("the-title.5") }
  end

  context ".sanitize_filename" do
    subject { described_class }
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
      expect(subject.sanitize_filename(%{title ((for "you", "Amy", and "John"))})).to eq("title-for-you-Amy-and-John")
    end

    it "should support titles with extra stuff" do
      expect(subject.sanitize_filename("title,for!")).to eq("title-for")
    end
  end

end
