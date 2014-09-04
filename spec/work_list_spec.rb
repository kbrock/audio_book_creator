require "spec_helper"

describe AudioBookCreator::WorkList do
  subject { described_class.new }
  before { subject << "a" }

  context "#with dups" do
    before { subject << "a" << "a" }

    it "dedups" do
      expect(subject.outstanding).to eq(%w(a))
    end
  end

  it "avoids nil" do
    subject << nil
    expect(subject.outstanding).to eq(%w(a))
  end

  context "#include?" do
    it { is_expected.to be_include('a') }

    it { expect(subject['a']).to be_truthy }
  end

  context "#shift" do
    it "removes entry" do
      expect(subject.shift).to eq("a")
      expect(subject.outstanding).to eq([])
    end
  end
end
