require 'spec_helper'

describe AudioBookCreator::ArrayWithCap do
  subject { described_class.new }

  context "#initialize with no params" do
    it { expect(subject.max).to be_nil }
    it { expect(subject).to eq([])}
  end

  context "#initialize with params" do
    subject { described_class.new(5) }
    it { expect(subject.max).to eq(5) }
    it { expect(subject).to eq([])}
  end

  context "with data" do
    before { subject << "a" }

    it { expect(subject).to eq(%w(a)) }

    it { is_expected.to be_include('a') }
  end

  context "with max" do
    before { subject.max = 2 }

    it "visits" do
      subject << "url1" << "url2"
      expect { subject << "url3" }.to raise_error(/visited 2 pages/)
    end
  end
end
