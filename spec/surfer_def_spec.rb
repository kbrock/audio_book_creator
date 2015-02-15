require 'spec_helper'

describe AudioBookCreator::SurferDef do
  context "with parameters" do
    subject { described_class.new("host", 5, true) }
    it { expect(subject.host).to eq("host") }
    it { expect(subject.max).to eq(5) }
    it { expect(subject.regen_html).to be_truthy }
  end

  context "with nils" do
    subject { described_class.new(nil, 5, false) }
    it { expect(subject.host).to be_nil }
    it { expect(subject.regen_html).not_to be_truthy }
  end
end
