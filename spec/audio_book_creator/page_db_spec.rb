require "spec_helper"
require 'tempfile'

describe AudioBookCreator::PageDb do
  subject { standard_db }

  # all of these tests are in memory
  # this is the only test that depends upon it
  context "with memory databases" do
    subject { standard_db(":memory:")}
    it "does not create a file" do
      # access key to trigger database creation
      subject["key"]
      expect(File).not_to be_exist(":memory:")
    end
  end

  describe "#initialize" do
    subject { described_class.new(":memory:", "tablename", true) }
    it { expect(subject.filename).to eq(":memory:") }
    it { expect(subject.table_name).to eq("tablename") }
    it { expect(subject.encode).to eq(true) }
  end

  it "works" do
    expect(subject).not_to be_nil
  end

  describe "#[]", "#[]=" do
    it "finds value" do
      subject["key"] = "value"

      expect(subject["key"]).to eq("value")
    end

    it "handles url keys" do
      key = "http://the.web.site.com/path/to/cgi?param1=x&param2=y#substuff"
      contents = "a" * 555
      subject[key] = contents

      expect(subject[key]).to eq(contents)
    end

    it "finds nothing" do
      expect(subject["key"]).to be_nil
    end

    it "sets nils" do
      subject["key"] = nil

      expect(subject["key"]).to eq(nil)
    end

    it "non injection" do
      subject["key"] = "null"

      expect(subject["key"]).to eq("null")
    end

    context "with encoding db" do
      subject { encoded_db }

      it "sets nils" do
        subject["key"] = nil

        expect(subject["key"]).to eq(nil)
      end

      it "non injection" do
        subject["key"] = "null"

        expect(subject["key"]).to eq("null")
      end

      it "sets hashes" do
        subject["key"] = {:name => "value"}

        expect(subject["key"]).to eq({:name => "value"})
      end

      it "finds nothing" do
        expect(subject["key"]).to be_nil
      end
    end
  end

  describe "#include?" do
    it "include good key" do
      subject["key"] = "value"
      expect(subject).to include("key")
    end

    it "doesnt include bad key" do
      expect(subject).not_to include("key")
    end
  end

  context "with prepopulated (file) database" do
    let(:tmp) { Tempfile.new("db") }

    before do
      # note, this is a different instantiation
      # that way we are testing that it actually saves to disk
      db = standard_db(tmp.path)
      db["key"] = "value"
    end

    after do
      tmp.close
      tmp.unlink
    end

    it "finds entry in previously created cache" do
      db = standard_db(tmp.path)
      expect(db["key"]).to eq("value")
    end

    it "creates a file" do
      expect(File.exist?(tmp.path)).to be_truthy
    end
  end

  # TODO: the legacy db seems to have all columns
  # so we are not testing the migration block of code
  context "with legacy (file) database" do
    let(:tmp) { Tempfile.new("db") }
    let(:now) { Time.now }

    before do
      db = legacy_standard_db(tmp.path)
      allow(Time).to receive(:now).and_return(now)
    end

    after do
      tmp.close
      tmp.unlink
    end

    it "finds extra columns" do
      db = standard_db(tmp.path)
      db["newkey"] = "value"

      expect(db.date("newkey")).to eq(now.utc.to_s)
    end
  end

  describe "#map" do
    it "enumerates" do
      subject["keyc"] = "v"
      subject["keya"] = "v"
      subject["keyz"] = "v"

      expect(subject.map { |(n, v)| "#{n}:#{v}" }).to eq(%w(keyc:v keya:v keyz:v))
    end
  end

  describe "#delete" do
    it "deletes rows" do
      subject["other"] = "v"
      subject["keya"] = "value"
      subject["keyb"] = "value"
      subject.delete "key%"
      expect(subject.map { |(n, v)| "#{n}:#{v}" }).to eq(%w(other:v))
    end
  end

  private

  def standard_db(filename = ":memory:")
    described_class.new(filename, "pages", false)
  end

  def encoded_db(filename = ":memory:")
    described_class.new(filename, "settings", true)
  end

  def legacy_standard_db(filename)
    described_class.new(filename, "settings", false, "name" => "text", "contents" => "blob")
  end
end
