require "spec_helper"

describe AudioBookCreator::Chapter do
  it "should have a title and chapter" do
    subject = described_class.new("book1", 1, "title", "body")

    expect(subject.book).to   eq("book1")
    expect(subject.number).to eq(1)
    expect(subject.title).to  eq("title")
    expect(subject.body).to   eq("body")
  end  

  it "matches for equality" do
    expect(described_class.new(nil, 1, "title", "body")).to eq(described_class.new(nil, 1, "title", "body"))
  end

  # TODO: need false case

end
