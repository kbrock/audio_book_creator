require "spec_helper"

describe AudioBookCreator::Speaker do
  let(:book_def) { AudioBookCreator::BookDef.new("dir") }
  subject { described_class.new(book_def)}
  it "should require a non empty chapter" do
    expect { subject.say(chapter(nil)) }.to raise_error
  end

  it "should do nothing if txt and mp4 file exist" do
    expect(File).to receive(:exist?).with("dir/chapter01.txt").and_return(true)
    expect(File).to receive(:exist?).with("dir/chapter01.m4a").and_return(true)

    expect(File).not_to receive(:write)
    expect_runner.not_to receive(:system)
    subject.say(chapter("content"))
  end

  it "should create text and mp4 file" do
    expect(File).to receive(:exist?).twice.and_return(false)
    expect(File).to receive(:write).with("dir/chapter01.txt", "the title\n\ncontent\n")

    expect_runner.to receive(:system)
      .with("say", "-v", "Vicki", "-r", "280", "-f", "dir/chapter01.txt", "-o", "dir/chapter01.m4a").and_return(true)
    subject.say(chapter("content"))
  end

  it "doesnt print if not verbose" do
    expect(File).to receive(:exist?).twice.and_return(false)
    expect(File).to receive(:write)

    expect_runner.to receive(:system).and_return(true)
    subject.say(chapter("content"))    
    expect_to_have_logged()
  end

  it "should output messages if set to verbose" do
    enable_logging
    expect(File).to receive(:exist?).twice.and_return(false)
    expect(File).to receive(:write)

    expect_runner.to receive(:system).and_return(true)
    subject.say(chapter("content"))
    expect_to_have_logged(/^run:/, "", "", "success")
  end

  it "should create text and mp4 file if they exist but are set to force" do
    subject.force = true
    expect(File).not_to receive(:exist?)
    expect(File).to receive(:write)

    expect_runner.to receive(:system).and_return(true)
    subject.say(chapter("content"))
  end

  it "should create a speaker with no options" do
    expect { described_class.new(book_def) }.not_to raise_error
  end

  it "should freak if no chapters are passed in" do
    expect { subject.say([]) }.to raise_error("Empty chapter")
  end

  private

  def expect_runner
    expect_any_instance_of(AudioBookCreator::Runner)
  end
end
