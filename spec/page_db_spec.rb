require_relative "spec_helper"
describe AudioBookCreator::PageDb do
  subject { described_class.new(":memory:") }

  it "should not create a file" do
    expect(File).not_to be_exist(":memory:")
  end

  it "should work" do
    expect(subject).not_to be_nil
  end

  it "should create cache value" do
    subject["key"] = "value"

    expect(subject["key"]).to eq("value")
  end

  it "should clear a database" do
    subject["key"] = "value"
    subject.clear

    expect(subject["key"]).to be_nil
  end

  it "should handle url keys" do
    key = "http://the.web.site.com/path/to/cgi?param1=x&param2=y#substuff"
    contents = "a" * 555
    subject[key] = contents
    expect(subject[key]).to eq(contents)
  end
end
