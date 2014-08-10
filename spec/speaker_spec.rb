require "spec_helper"
require "open3"

describe AudioBookCreator::Speaker do
  it "should require a non empty chapter" do
    expect { subject.say(chapter(nil)) }.to raise_error
  end

  it "should do nothing if txt and mp4 file exist" do
    expect(File).to receive(:exist?).twice.and_return(true)

    expect(File).not_to receive(:write)
    expect(Open3).not_to receive(:capture3)
    subject.say(chapter("content"))
  end

  it "should create text and mp4 file" do
    expect(File).to receive(:exist?).twice.and_return(false)

    expect(File).to receive(:write)
    expect(Open3).to receive(:capture3)
      .and_return(["txt", nil, double("cmd", exitstatus: 0)])
    subject.say(chapter("content"))
  end

  it "should output messages if set to verbose" do
    subject.verbose = true
    expect(File).to receive(:exist?).twice.and_return(false)

    expect(File).to receive(:write)
    expect(Open3).to receive(:capture3)
      .and_return(["command text", nil, double("cmd", exitstatus: 0)])

    expect(subject).to receive(:puts).with(/^run:/)
    expect(subject).to receive(:puts).with("success")
    expect(subject).to receive(:puts).with("command text")

    subject.say(chapter("content"))
  end

  it "should create text and mp4 file if they exist but are set to force" do
    allow(File).to receive(:exist?).and_return(true)
    subject.force = true

    expect(File).to receive(:write)
    expect(Open3).to receive(:capture3)
      .and_return(["txt", nil, double("cmd", exitstatus: 0)])
    subject.say(chapter("content"))
  end

  private
end
