require 'spec_helper'

describe AudioBookCreator::CachedHash do
  let(:cache) { {} }
  let(:main)  { {} }
  subject { described_class.new(cache, main) }

  context "#with cached content" do
    let(:cache) { {:key => "val"} }
    it { expect(subject[:key]).to eq("val") }
    it { subject[:key] ; expect(main[:key]).to be_nil }
  end

  context "#with main content" do
    let(:main) { {:key => "val"} }
    it { expect(subject[:key]).to eq("val") }
    it { subject[:key] ; expect(cache[:key]).to eq("val") }
  end
end
