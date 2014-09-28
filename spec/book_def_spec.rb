require 'spec_helper'

describe AudioBookCreator::BookDef do
  context "with single parameter" do
    subject { described_class.new("dir") }
    it { expect(subject.base_dir).to eq("dir") }
    it { expect(subject.title).to eq("dir") }
    it { expect(subject.author).to eq("Vicki") }
    it { expect(subject.max_paragraphs).to eq(nil) }
    it { expect(subject.cache_filename).to eq("dir/pages.db") }
  end

  context "with all parameters" do
    subject { described_class.new("the title", "author", "dir", 5, "cachename") }
    it { expect(subject.base_dir).to eq("dir") }
    it { expect(subject.title).to eq("the title") }
    it { expect(subject.author).to eq("author") }
    it { expect(subject.max_paragraphs).to eq(5) }
    it { expect(subject.cache_filename).to eq("cachename") }

    it { expect(subject.filename).to eq("the-title.m4b") }

    context "#chapter_text_filename" do
      let(:chapter) { AudioBookCreator::Chapter.new(number: 3) }

      it { expect(subject.chapter_text_filename(chapter)).to eq("dir/chapter03.txt") }
    end

    context "#chapter_sound_filename" do
      let(:chapter) { AudioBookCreator::Chapter.new(number: 2) }
      it { expect(subject.chapter_sound_filename(chapter)).to eq("dir/chapter02.m4a") }
    end
  end
end
