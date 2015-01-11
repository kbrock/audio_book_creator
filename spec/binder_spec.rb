require "spec_helper"

describe AudioBookCreator::Binder do
  let(:book_def) { AudioBookCreator::BookDef.new("title", nil, "dir") }
  let(:speaker_def) { AudioBookCreator::SpeakerDef.new }
  subject { described_class.new(book_def, speaker_def) }

  it "should require a chapter" do
    expect { subject.create([]) }.to raise_error
  end

  it "should do nothing if m4b exists" do
    expect(File).to receive(:exist?).with("title.m4b").and_return(true)

    expect_runner.not_to receive(:system)
    subject.create([spoken_chapter])
  end

  it "should base filename on title and sanitize it" do
    book_def.title = "the title"
    expect(File).to receive(:exist?).with("the-title.m4b").and_return(true)
    subject.create([spoken_chapter])
  end

  it "should create text and m4a file" do
    expect(File).to receive(:exist?).with("title.m4b").and_return(false)

    expect_runner.to receive(:system)
      .with("abbinder", "-a", "Vicki", "-t", "title", "-b", "32", "-c", "1",
            "-r", "22050", "-g", "Audiobook", "-l", "7", "-o", "title.m4b",
            "@the title@", "dir/chapter01.m4a").and_return(true)
    subject.create([spoken_chapter])
  end


  context "with itunes" do
    subject { described_class.new(book_def, speaker_def, itunes: true ) }
    it "should load into itunes" do
      expect(File).to receive(:exist?).with("title.m4b").and_return(false)

      expect_runner.to receive(:system)
        .with("abbinder", "-A", "-a", "Vicki", "-t", "title", "-b", "32", "-c", "1",
              "-r", "22050", "-g", "Audiobook", "-l", "7", "-o", "title.m4b",
              "@the title@", "dir/chapter01.m4a").and_return(true)
      subject.create([spoken_chapter])
    end
  end

  it "outputs messages if set to verbose" do
    enable_logging
    expect(File).to receive(:exist?).and_return(false)

    expect_runner.to receive(:system).and_return(true)

    subject.create([spoken_chapter])
    expect_to_have_logged(/^run:/, "", "","success")
  end

  it "outputs no messages if set to non verbose" do
    expect(File).to receive(:exist?).and_return(false)

    expect_runner.to receive(:system).and_return(true)
    subject.create([spoken_chapter])
    expect_to_have_logged()
  end

  context "with force" do
    subject { described_class.new(book_def, speaker_def, force: true ) }

    it "should create m4a if exists" do
      expect(File).not_to receive(:exist?)

      expect_runner.to receive(:system).and_return(true)
      subject.create([spoken_chapter])
    end
  end

  context "with false force" do
    subject { described_class.new(book_def, speaker_def, force: false ) }

    it "should not create m4a if exists" do
      expect(File).to receive(:exist?).and_return(true)

      expect_runner.not_to receive(:system)
      subject.create([spoken_chapter])
    end
  end

  it "requires chapters to be passed in" do
    expect { subject.create(nil) }.to raise_error("No Chapters")
    expect { subject.create([]) }.to raise_error("No Chapters")
  end

  private

  def expect_runner
    expect_any_instance_of(AudioBookCreator::Runner)
  end
end
