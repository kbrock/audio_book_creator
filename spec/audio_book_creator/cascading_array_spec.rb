require 'spec_helper'

describe AudioBookCreator::CascadingArray do
  let(:pages) { [:p1, :p2] }
  let(:chapters) { [:ch1, :ch2] }
  subject { described_class.new(pages, chapters) }

  it { is_expected.to be_include(:p1) }
  it { is_expected.to be_include(:ch2) }
  it { is_expected.not_to be_include(:ch4) }


  it "includes even after it is empty" do
    4.times { subject.shift }
    expect(subject.shift).to be_nil
    expect(subject).to be_include(:p1)
    expect(subject).to be_include(:ch1)
  end

  it "includes later added values" do
    subject.add_page(:p3)
    subject.add_chapter(:c3)
    expect(subject.each.to_a).to eq([:p1,:p2,:p3,:ch1,:ch2,:c3])
    expect(subject).to be_include(:p3)
    expect(subject).to be_include(:c3)
  end

  it "takes primary before secondary" do
    expect(subject.shift).to eq(:p1)
    expect(subject.shift).to eq(:p2)
    expect(subject.shift).to eq(:ch1)
    expect(subject.shift).to eq(:ch2)
    expect(subject.shift).to be_nil
  end

  it "enumerates" do
    ret = []
    subject.each { |x| ret << x }
    expect(ret).to eq([:p1,:p2,:ch1,:ch2])
  end

  it "non block enumerates" do
    expect(subject.each).to be_a(Enumerator)
    expect(subject.each.to_a).to eq([:p1,:p2,:ch1,:ch2])
  end


  it "puts pages into primary" do
    subject.add_page(:p3)
    expect(subject.each.to_a).to eq([:p1,:p2,:p3,:ch1,:ch2])
  end

  it "puts non duplicate pages into primary" do
    subject.add_unique_page(:p3)
    subject.add_unique_page(:p3)
    expect(subject.each.to_a).to eq([:p1,:p2,:p3,:ch1,:ch2])
  end

  it "puts non duplicate chapters into secondary" do
    subject.add_unique_chapter(:ch3)
    subject.add_unique_chapter(:ch3)
    expect(subject.each.to_a).to eq([:p1,:p2,:ch1,:ch2,:ch3])
  end
end
