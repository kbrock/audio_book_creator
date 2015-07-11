require "spec_helper"

describe AudioBookCreator::Speaker do
  let(:book_def) { AudioBookCreator::BookDef.new("dir") }
  let(:speaker_def) { AudioBookCreator::SpeakerDef.new(:regen_audio => false) }
  subject { described_class.new(speaker_def, book_def) }
  it "should require a non empty chapter" do
    expect_runner.not_to receive(:system)
    expect { subject.say(chapter(nil)) }.to raise_error("Empty Chapter")
  end

  it "should do nothing if txt and mp4 file exist" do
    expect(File).to receive(:exist?).with("dir/chapter01.txt").and_return(true)
    expect(File).to receive(:exist?).with("dir/chapter01.m4a").and_return(true)

    expect(File).not_to receive(:write)
    expect_runner.not_to receive(:system)
    expect(subject.say(chapter)).to eq(spoken_chapter("the title", "dir/chapter01.m4a"))
  end

  it "should create text and mp4 file" do
    expect(File).to receive(:exist?).twice.and_return(false)
    expect(File).to receive(:write).with("dir/chapter01.txt", "the title\n\ncontent\n")

    expect_runner.to receive(:system)
      .with("say", "-v", "Vicki", "-r", "280", "-f", "dir/chapter01.txt", "-o", "dir/chapter01.m4a").and_return(true)
    subject.say(chapter)
  end

  it "doesnt print if not verbose" do
    expect(File).to receive(:exist?).twice.and_return(false)
    expect(File).to receive(:write)

    expect_runner.to receive(:system).and_return(true)
    subject.say(chapter)
    expect_to_have_logged()
  end

  it "should output messages if set to verbose" do
    enable_logging
    expect(File).to receive(:exist?).twice.and_return(false)
    expect(File).to receive(:write)

    expect_runner.to receive(:system).and_return(true)
    subject.say(chapter)
    expect_to_have_logged(/^run:/, "", "", "success")
  end

  context "with force" do
    before { speaker_def.regen_audio = true}
    subject { described_class.new(speaker_def, book_def) }

    it "should create text and mp4 file if they exist but are set to force" do
      expect(File).not_to receive(:exist?)
      expect(File).to receive(:write)

      expect_runner.to receive(:system).and_return(true)
      subject.say(chapter)
    end
  end

  it "should freak if no chapters are passed in" do
    expect_runner.not_to receive(:system)
    expect { subject.say([]) }.to raise_error("Empty Chapter")
  end

  context "#make_directory_structure" do
    it "should create base directory" do
      expect_runner.not_to receive(:system)
      expect(File).to receive(:exist?).with(subject.book_def.base_dir).and_return(false)
      expect(FileUtils).to receive(:mkdir).with(subject.book_def.base_dir)
      subject.make_directory_structure
    end

    it "should not create base directory if it exists" do
      expect_runner.not_to receive(:system)
      expect(File).to receive(:exist?).with(subject.book_def.base_dir).and_return(true)
      expect(FileUtils).not_to receive(:mkdir)
      subject.make_directory_structure
    end
  end

  context "#chapter_text_filename" do
    let(:chapter) { AudioBookCreator::Chapter.new(number: 3) }

    it do
      expect_runner.not_to receive(:system)
      expect(subject.chapter_text_filename(chapter)).to eq("dir/chapter03.txt")
    end
  end

  context "#chapter_sound_filename" do
    let(:chapter) { AudioBookCreator::Chapter.new(number: 2) }
    it do
      expect_runner.not_to receive(:system)
      expect(subject.chapter_sound_filename(chapter)).to eq("dir/chapter02.m4a")
    end
  end

  private

  def expect_runner
    expect_any_instance_of(AudioBookCreator::Runner)
  end
end
