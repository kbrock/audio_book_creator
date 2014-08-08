require 'spec_helper'

# NOTE: cli class is not in the path by default
#       it is only included by running the command
require 'audio_book_creator/cli'

describe AudioBookCreator::Cli do
  it "should treat first arguments as a url" do
    subject.parse(%w(title url1))
    expect(subject[:title]).to eq("title")
    expect(subject[:urls]).to eq(%w(url1))
  end

  it "should require 2 parameters" do
    expect(subject).to receive(:puts).with(/url/, /Usage/)
    expect(subject).to receive(:exit)
    subject.parse(%w(title_only))
  end

  it "should provide version" do
    expect(subject).to receive(:puts).with(/#{AudioBookCreator::VERSION}/)
    expect(subject).to receive(:exit)
    # NOTE: since we are catching exit, it is continuing through the rest of the loop
    # we are passing in all required parameters to avoid those raising errors
    subject.parse(%w(--version title url))
  end

  it "should provide help" do
    expect(subject).to receive(:puts).with(/Usage/)
    expect(subject).to receive(:exit)
    # NOTE: since we are catching exit, it is continuing through the rest of the loop
    # we are passing in all required parameters to avoid those raising errors
    subject.parse(%w(--help title url))
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

  context "#follow" do
    it "should default to all links" do
      subject.parse(%w(title url1))
      expect(subject[:follow]).to eq("a")
    end

    it "should respect --follow" do
      subject.parse(["--follow", ".navbar a[title='page']", "title", "url1"])
      expect(subject[:follow]).to eq(".navbar a[title='page']")
    end
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

  # components

  it "should populate page cache" do
    subject[:database] = ":memory:"
    expect(subject.page_cache.filename).to eq(subject[:database])
  end

  it "should populate spider" do
    subject[:load_from_cache] = false
    expect(subject.spider.load_from_cache).to eq(subject[:load_from_cache])
  end

  # private method

  context "#option_hash" do
    it "should pull out params by array" do
      subject[:a] = "a"
      subject[:b] = "b"
      subject[:c] = "c"
      expect(subject.option_hash(:a, :b)).to eq({a: "a", b: "b"})
    end

    it "should pull out params by array" do
      subject[:a] = "a"
      subject[:b] = "b"
      subject[:c] = "c"
      expect(subject.option_hash([:a, :b])).to eq({a: "a", b: "b"})
    end

    it "should pull out params by array" do
      subject[:a] = "a"
      subject[:b] = "b"
      subject[:c] = "c"
      expect(subject.option_hash(a: :b, b: :c)).to eq({a: "b", b: "c"})
    end
  end

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
