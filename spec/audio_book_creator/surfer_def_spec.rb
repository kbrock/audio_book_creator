require 'spec_helper'

describe AudioBookCreator::SurferDef do
  context "with parameters" do
    subject { described_class.new(5, true) }
    it { expect(subject.max).to eq(5) }
    it { expect(subject.regen_html).to be_truthy }
  end

  context "with nils" do
    subject { described_class.new }
    it { expect(subject.regen_html).not_to be_truthy }
  end
end
