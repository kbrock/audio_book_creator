require "spec_helper"

describe AudioBookCreator::Chapter do
  it "should have a title and chapter" do
    subject = described_class.new("title", "body")

    expect(subject.title).to eq("title")
    expect(subject.body).to eq("body")
  end  

  it "matches for equality" do
    expect(described_class.new("title", "body")).to eq(described_class.new("title", "body"))
  end
end
