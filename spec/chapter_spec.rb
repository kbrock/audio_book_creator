require "spec_helper"

describe AudioBookCreator::Chapter do
  subject { described_class.new(number: 1, title: "title1", body: ["body1"]) }

  it "should set number" do
    expect(subject.number).to eq(1)
  end

  it "should set title" do
    expect(subject.title).to eq("title1")
  end

  it "should set body" do
    expect(subject.body).to eq("body1")
  end

  it "should support string body (mostly for tests)" do
    expect(described_class.new(body: "body1").body).to eq("body1")
  end

  it "should support string multiple body entries" do
    expect(described_class.new(body: ["body1", nil, "body2"]).body).to eq("body1\n\nbody2")
  end

  it "should support other values for number, title, and body" do
    other = described_class.new(number: 2, title: "title2")
    expect(other.number).to eq(2)
    expect(other.title).to eq("title2")
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

  context "#eq1" do
    it "should understand ==" do
      expect(subject).to eq(described_class.new(number: 1, title: "title1", body: "body1"))
    end

    it "should understand != nil" do
      expect(subject).not_to eq(nil)
    end

    it "should understand != different class" do
      expect(subject).not_to eq("abc")
    end

    it "should understand != number" do
      expect(subject).not_to eq(described_class.new(number: 2, title: "title1", body: "body1"))
    end

    it "should understand != title" do
      expect(subject).not_to eq(described_class.new(number: 1, title: "title2", body: "body1"))
    end

    it "should understand != body" do
      expect(subject).not_to eq(described_class.new(number: 1, title: "title1", body: "body2"))
    end
  end
end
