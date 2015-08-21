require "spec_helper"

describe AudioBookCreator::WebPage do
  describe "#initialize" do
    it "sets url" do
      expect(described_class.new("url", nil).url).to eq("url")
    end

    it "sets body" do
      expect(described_class.new(nil, "body").body).to eq("body")
    end
  end

  describe "#empty?" do
    it "detects blank" do
      expect(described_class.new(nil, "")).to be_empty
    end

    it "detects negative" do
      expect(described_class.new(nil,"body")).not_to be_empty
    end
  end

  describe "#css" do
    subject { described_class.new("url", "<h1>body</h1><h2></h2><p>p1</p><p>p2</p>") }
    it "fetches no element" do
      expect(subject.css("title")).to eq([])
    end

    it "fetches blank element" do
      expect(subject.css("h2")).to eq([""])
    end

    it "fetches single element" do
      expect(subject.css("h1")).to eq(["body"])
    end

    it "fetches multi element" do
      expect(subject.css("p text()")).to eq(%w(p1 p2))
    end
  end

  context "#eql" do
    subject { described_class.new("url", "body") }
    it "should understand ==" do
      expect(subject).to eq(Class.new(described_class).new("url", "body"))
    end

    it "should understand != nil" do
      expect(subject).not_to eq(nil)
    end

    it "should understand != different class" do
      expect(subject).not_to eq("abc")
    end

    it "should understand != url" do
      expect(subject).not_to eq(described_class.new("url2", "body"))
    end

    it "should understand != body" do
      expect(subject).not_to eq(described_class.new("url", "body2"))
    end
  end
end
