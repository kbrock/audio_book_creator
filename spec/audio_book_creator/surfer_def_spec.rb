require 'spec_helper'

describe AudioBookCreator::SurferDef do
  context "with parameters" do
    subject { described_class.new(5, true, true) }
    it { expect(subject.max).to eq(5) }
    it { expect(subject.regen_html).to eq(true) }
    it { expect(subject.existing).to eq(true) }
  end

  context "with nils" do
    subject { described_class.new }
    it { expect(subject.max).to eq(nil) }
    it { expect(subject.regen_html).to eq(nil) }
    it { expect(subject.existing).to eq(false) }
  end
end
