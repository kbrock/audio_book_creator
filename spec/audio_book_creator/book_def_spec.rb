require 'spec_helper'

describe AudioBookCreator::BookDef do
  context "with no parameter" do
    subject { described_class.new }
    it { expect(subject.title).to eq(nil) }
    it { expect(subject.author).to eq("Vicki") }
    it { expect(subject.urls).to be_nil }
    it { expect(subject.itunes).to be_truthy }
  end

  context "with title" do
    subject { described_class.new("dir") }
    it { expect(subject.base_dir).to eq("dir") }
    it { expect(subject.title).to eq("dir") }
  end

  context "with all parameters" do
    subject { described_class.new("the title", "author", "dir", %w(a b), false) }
    it { expect(subject.base_dir).to eq("dir") }
    it { expect(subject.title).to eq("the title") }
    it { expect(subject.author).to eq("author") }
    it { expect(subject.filename).to eq("the-title.m4b") }
    it { expect(subject.urls).to eq(%w(a b)) }
    it { expect(subject.itunes).to be_falsy }
  end

  context "with all parameters alt" do
    subject { described_class.new("the title", "author", "dir", %w(a b), true) }
    it { expect(subject.itunes).to be_truthy }
  end

  describe "#base_dir (derived)" do
    subject { described_class.new }

    it "supports titles with spaces" do
      subject.title = %{title ((for "you", "Amy", and "John"))}
      expect(subject.base_dir).to eq("title-for-you-Amy-and-John")
    end

    it "supports titles with extra stuff" do
      subject.title = "title,for!"
      expect(subject.base_dir).to eq("title-for")
    end

    it "overrides" do
      subject.base_dir = "dir"
      subject.title = "title"
      expect(subject.base_dir).to eq("dir")
    end
  end

  context "#unique_urls" do
    subject { described_class.new("dir") }
    before { subject.urls = %w(http://site.com/title http://site.com/title http://site.com/title2) }
    it { expect(subject.unique_urls).to eq(%w(http://site.com/title http://site.com/title2)) }
  end

  describe "#filename (derived)" do
    subject { described_class.new }

    it "adds extension" do
      subject.title = "title"
      expect(subject.filename).to eq("title.m4b")
    end

    it "supports spaces" do
      subject.title = "the title"
      expect(subject.filename).to eq("the-title.m4b")
    end
  end
end
