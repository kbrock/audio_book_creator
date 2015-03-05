require "spec_helper"
require 'tempfile'

describe AudioBookCreator::PageDb do
  subject { described_class.new(":memory:") }

  # all of these tests are in memory
  # this is the only test that depends upon it
  context "with memory databases" do
    it "does not create a file" do
      # access key to trigger database creation
      subject["key"]
      expect(File).not_to be_exist(":memory:")
    end
  end

  it "works" do
    expect(subject).not_to be_nil
  end

  it "creates cache value" do
    subject["key"] = "value"

    expect(subject["key"]).to eq("value")
  end

  it "include good key" do
    subject["key"] = "value"
    expect(subject).to include("key")
  end

  it "doesnt include bad key" do
    expect(subject).not_to include("key")
  end

  context "with prepopulated (file) database" do
    let(:tmp) { Tempfile.new("db") }

    before do
      db = described_class.new(tmp.path)
      db["key"] = "value"
    end

    after do
      tmp.close
      tmp.unlink
    end

    it "finds entry in previously created cache" do
      db = described_class.new(tmp.path)
      expect(db["key"]).to eq("value")
    end

    it "creates a file" do
      expect(File.exist?(tmp.path)).to be_truthy
    end
  end

  it "handles url keys" do
    key = "http://the.web.site.com/path/to/cgi?param1=x&param2=y#substuff"
    contents = "a" * 555
    subject[key] = contents
    expect(subject[key]).to eq(contents)
  end

  it "supports enumerable (map)" do
    subject["keyc"] = "v"
    subject["keya"] = "v"
    subject["keyz"] = "v"

    expect(subject.map { |(n, v)| "#{n}:#{v}" }).to eq(%w(keyc:v keya:v keyz:v))
  end

end
