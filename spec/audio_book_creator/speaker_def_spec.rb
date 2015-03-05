require 'spec_helper'

describe AudioBookCreator::SpeakerDef do
  context "with no parameters" do
    subject { described_class.new }
    # for speaking the chapter
    it { expect(subject.voice).to eq("Vicki") }
    it { expect(subject.rate).to eq(280) }
    # for binding the book
    it { expect(subject.channels).to eq(1) }
    it { expect(subject.bit_rate).to eq(32) }
    it { expect(subject.max_hours).to eq(7) }
    it { expect(subject.sample_rate).to eq(22_050) }
    it { expect(subject.regen_audio).to be_falsy }
  end

  context "with parameters" do
    subject do
        described_class.new(
            voice: "Serena",
            rate: 360,
            channels: 2,
            bit_rate: 64,
            max_hours: 2,
            sample_rate: 44100,
            regen_audio: true,
        )
    end

    it { expect(subject.voice).to eq("Serena") }
    it { expect(subject.rate).to eq(360) }
    # for binding the book
    it { expect(subject.channels).to eq(2) }
    it { expect(subject.bit_rate).to eq(64) }
    it { expect(subject.max_hours).to eq(2) }
    it { expect(subject.sample_rate).to eq(44_100) }
    it { expect(subject.regen_audio).to be_truthy }
  end
end
