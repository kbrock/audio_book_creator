require "spec_helper"

describe AudioBookCreator::Chapter do
  subject { described_class.new(number: 1, title: "title1", body: "body1") }

  it "should set number" do
    expect(subject.number).to eq(1)
  end

  it "should set title" do
    expect(subject.title).to eq("title1")
  end

  it "should set body" do
    expect(subject.body).to eq("body1")
  end

  it "should set filename" do
    expect(subject.filename).to eq("chapter01")
  end

  it "should provide to_s" do
    expect(subject.to_s).to eq("title1\n\nbody1\n")
  end

  it { expect(subject).not_to be_empty }

  it "should understand empty" do
    expect(described_class.new).to be_empty
  end

  it "should understand ==" do
    expect(subject).to eq(described_class.new(number: 1, title: "title1", body: "body1"))
  end

  it "should understand !=" do
    expect(subject).not_to eq(described_class.new(number: 2, title: "title1", body: "body1"))
  end
end
