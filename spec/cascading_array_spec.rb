require 'spec_helper'

describe AudioBookCreator::CascadingArray do
  let(:pages) { [:p1, :p2] }
  let(:chapters) { [:ch1, :ch2] }
  subject { described_class.new(pages, chapters) }

  it { is_expected.to be_include(:p1) }
  it { is_expected.to be_include(:ch2) }
  it { is_expected.not_to be_include(:ch4) }

  it "takes primary before secondary" do
    expect(subject.shift).to eq(:p1)
    expect(subject.shift).to eq(:p2)
    expect(subject.shift).to eq(:ch1)
    expect(subject.shift).to eq(:ch2)
    expect(subject.shift).to be_nil
  end

  it "puts into end of primary" do
    subject << :p3 << :p4
    expect(subject.shift).to eq(:p1)
    expect(subject.shift).to eq(:p2)
    expect(subject.shift).to eq(:p3)
    expect(subject.shift).to eq(:p4)
    expect(subject.shift).to eq(:ch1)
  end
end
