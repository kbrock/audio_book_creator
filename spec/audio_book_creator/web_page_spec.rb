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

  describe "#links" do
    let(:root) { uri("") }
    let(:subject) { web_page(root, "title", "<a href='tgt1'>a</a><a href='tgt2'>a</a>")}

    it { expect(subject.links('h1')).to be_empty}
    it { expect(subject.links('a')).to eq(uri(%w(tgt1 tgt2))) }
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
  end

  describe ".map_urls" do
    subject { described_class }
    it { expect(subject.map_urls(site(%w(a b c#d)))).to eq(uri(%w(a b c))) }
    it { expect(subject.map_urls(uri(%w(a b c#d)))).to eq(uri(%w(a b c))) }
  end
end
