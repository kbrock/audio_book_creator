require 'spec_helper'

describe AudioBookCreator::SurferDef do
  context "with parameters" do
    subject { described_class.new("host", 5, true, "database") }
    it { expect(subject.host).to eq("host") }
    it { expect(subject.max).to eq(5) }
    it { expect(subject.regen_html).to be_truthy }
    it { expect(subject.cache_filename).to eq("database")}
  end

  context "with nils" do
    subject { described_class.new(nil, 5, false, nil) }
    it { expect(subject.host).to be_nil }
    it { expect(subject.regen_html).not_to be_truthy }
  end
end
