require "spec_helper"

describe AudioBookCreator::Speaker do
  it "should require a non empty chapter" do
    expect { subject.say(chapter(nil)) }.to raise_error
  end

  it "should do nothing if txt and mp4 file exist" do
    expect(File).to receive(:exist?).twice.and_return(true)

    expect(File).not_to receive(:write)
    expect_runner.not_to receive(:system)
    subject.say(chapter("content"))
  end

  it "should create text and mp4 file" do
    expect(File).to receive(:exist?).twice.and_return(false)
    expect(File).to receive(:write)

    expect_runner.to receive(:system)
      .with("say", "-v", "Vicki", "-r", "320", "-f", "/chapter01.txt", "-o", "/chapter01.m4a").and_return(true)
    subject.say(chapter("content"))
  end

  it "should output messages if set to verbose" do
    subject.verbose = true
    expect(File).to receive(:exist?).twice.and_return(false)
    expect(File).to receive(:write)

    expect_runner.to receive(:system).and_return(true)
    expect_runner.to receive(:puts).with(/^run:/)
    expect_runner.to receive(:puts).with("success")
    expect_runner.to receive(:puts).with("").twice

    subject.say(chapter("content"))
  end

  it "should create text and mp4 file if they exist but are set to force" do
    subject.force = true
    expect(File).not_to receive(:exist?)
    expect(File).to receive(:write)

    expect_runner.to receive(:system).and_return(true)
    subject.say(chapter("content"))
  end

  private

  def expect_runner
    expect_any_instance_of(AudioBookCreator::Runner)
  end
end
