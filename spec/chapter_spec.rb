require "spec_helper"

describe AudioBookCreator::Chapter do
  subject { described_class.new(book: "book1", number: 1, title: "title", body: "body") }

  it "should set book" do
    expect(subject.book).to   eq("book1")
  end

  it "should set number" do
    expect(subject.number).to eq(1)
  end

  it "should set title" do
    expect(subject.title).to eq("title")
  end

  it "should set body" do
    expect(subject.body).to eq("body")
  end

  it "should set filename" do
    expect(subject.filename).to eq("book1/chapter01")
  end

  it "should provide to_s" do
    expect(subject.to_s).to eq("title\n\nbody\n")
  end

  it { expect(subject).not_to be_empty }

  it "should understand empty" do
    expect(described_class.new).to be_empty
  end

  it "should understand ==" do
    expect(subject).to eq(described_class.new(book: "book1", number: 1, title: "title", body: "body"))
  end

  it "should understand !=" do
    expect(subject).not_to eq(described_class.new(book: "book2", number: 1, title: "title", body: "body"))
  end
end
