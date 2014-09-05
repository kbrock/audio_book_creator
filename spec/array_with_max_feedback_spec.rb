require 'spec_helper'

describe AudioBookCreator::ArrayWithMaxFeedback do
  subject { described_class.new(max: nil) }

  context "#initialize" do
    # do we need to support this case?
    it "supports no parameters" do
      expect(described_class.new.max).to be_nil
    end

    it "supports parameters" do
      expect(described_class.new(max: 5).max).to eq(5)
    end
  end

  context "with data" do
    before { subject << "a" }

    it { expect(subject.map(&:to_s)).to eq(%w(a)) }

    it { is_expected.to be_include('a') }

    it { expect(subject['a']).to be_truthy }
  end

  context "with dups" do
    before { subject << "a" << "a" }

    it "dedups" do
      expect(subject.map(&:to_s)).to eq(%w(a))
    end
  end

  it "avoids nil" do
    subject << nil
    expect(subject.map(&:to_s)).to eq([])
  end

  context "with max" do
    before { subject.max = 2 }

    it "visits" do
      subject << "url1"
      subject << "url2"
      expect { subject << "url3" }.to raise_error(/visited 2 pages/)
    end

    context "and verbose" do
      before { verbose_logging }

      it "logs" do
        expect_to_log("visit url1 [1/2]", "visit url2 [2/2]")
        subject << "url1"
        subject << "url2"
      end
    end
  end

  context "when verbose" do
    before { verbose_logging }

    it "logs" do
      expect_to_log("visit url1 [1]", "visit url2 [2]")
      subject << "url1"
      subject << "url2"
    end
  end
end
