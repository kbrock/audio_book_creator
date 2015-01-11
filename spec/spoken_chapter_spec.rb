require "spec_helper"

describe AudioBookCreator::SpokenChapter do
  subject { described_class.new("title", "filename") }

  it { expect(subject.title).to eq("title") }
  it { expect(subject.filename).to eq("filename") }
end
