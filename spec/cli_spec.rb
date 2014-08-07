require 'spec_helper'

# NOTE: cli class is only included by running the command
require 'audio_book_creator/cli'

describe AudioBookCreator::Cli do
  it "should treat first arguments as a url" do
    subject.parse(%w(title url1))
    expect(subject[:title]).to eq("title")
    expect(subject[:urls]).to eq(%w(url1))
  end

  it "should know base directory" do
    subject.parse(%w(title url1))
    expect(subject.base_dir).to eq("title")
  end

  it "should create base directory" do
    subject[:title] = "base_directory"
    expect(File).to receive(:exist?).and_return(false)
    expect(FileUtils).to receive(:mkdir)
    subject.make_directory_structure
  end

  it "should stick database under base directory" do
    subject.parse(%w(title url1))
    expect(subject[:database]).to eq("title/pages.db")    
  end

  it "should become verbose" do
    subject.parse(%w(-v title url1))
    expect(subject[:verbose]).to be_truthy
  end

  context "#max" do
    it "should have default" do
      subject.parse(%w(title url1))
      expect(subject[:max]).to eq(10)
    end

    it "should be setable" do
      subject.parse(%w(--max 25 title url1))
      expect(subject[:max]).to eq(25)
    end

    it "should be removable" do
      subject.parse(%w(--no-max title url1))
      expect(subject[:max]).to be_nil
    end
  end

  # private method
  context "#default" do
    it "should properly default values" do
      subject[:test] = nil
      subject.default(:test, 5)
      expect(subject[:test]).to eq(5)
    end

    it "should not default false" do
      subject[:test] = false
      subject.default(:test, true)
      expect(subject[:test]).to be_falsy
    end
  end
end
