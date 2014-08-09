require 'spec_helper'

# NOTE: cli class is not in the path by default
#       it is only included by running the command
require 'audio_book_creator/cli'

describe AudioBookCreator::Cli do
  it "should treat first arguments as a url" do
    subject.parse(%w(title http://site.com/))
    expect(subject[:title]).to eq("title")
    expect(subject[:urls]).to eq(%w(http://site.com/))
  end

  it "should require 2 parameters" do
    expect(subject).to receive(:puts).with(/url/, /Usage/)
    expect(subject).to receive(:exit)
    subject.parse(%w(title_only))
  end

  # NOTE: these tests are a little wonky since they call exit
  # keep title and url in there for now
  context "#informational" do
    it "should provide version" do
      expect(subject).to receive(:puts).with(/#{AudioBookCreator::VERSION}/)
      expect(subject).to receive(:exit)
      subject.parse(%w(--version title http://site.com/))
    end

    it "should provide help" do
      expect(subject).to receive(:puts).with(/Usage/)
      expect(subject).to receive(:exit)
      # NOTE: since we are catching exit, it is continuing through the rest of the loop
      # we are passing in all required parameters to avoid those raising errors
      subject.parse(%w(--help title http://site.com/))
    end

    it "should provide help" do
      expect(subject).to receive(:puts).with(/Usage/)
      expect(subject).to receive(:exit)
      # NOTE: since we are catching exit, it is continuing through the rest of the loop
      # we are passing in all required parameters to avoid those raising errors
      subject.parse(%w(-h title http://site.com/))
    end
  end

  context "#make_directory_structure" do
    it "should create base directory" do
      expect(File).to receive(:exist?).with("title").and_return(false)
      expect(FileUtils).to receive(:mkdir)
      subject.parse(%w(title http://site.com/))
      subject.make_directory_structure
    end
  end

  context "#page_cache" do
    it "should have databse based upon title" do
      subject.parse(%w(title http://site.com/))
      expect(subject.page_cache.filename).to eq("title/pages.db")
      # defaults
      expect(subject.page_cache.force).not_to be_truthy
    end

    it "should support force" do
      subject.parse(%w(title http://site.com/ --force-html))
      expect(subject.page_cache.force).to be_truthy
    end
  end

  context "#spider" do
    it "should set url" do
      subject.parse(%w(title http://www.site.com/))
      # DARN:
      # expect(subject.spider.outstanding).to eq(%w(http://www.site.com/))
      expect(subject[:urls]).to eq(%w(http://www.site.com/))
      # defaults
      expect(subject.spider.verbose).not_to be_truthy
      expect(subject.spider.max).to eq(10)
      expect(subject.spider).not_to be_multi_site
    end

    it "should be verbose" do
      subject.parse(%w(title http://www.site.com/ -v))
      expect(subject.spider.verbose).to be_truthy
    end

    it "should support follow" do
      subject.parse(%w(title http://www.site.com/ --follow a.next_page))
      # DARN: (move into separate class)
      expect(subject[:follow]).to eq("a.next_page")
    end

    it "should have no max" do
      subject.parse(%w(title http://www.site.com/ --no-max))
      expect(subject.spider.max).to be_nil
    end

    it "should have a max" do
      subject.parse(%w(title http://www.site.com/ --max 20))
      expect(subject.spider.max).to eq(20)
    end

    it "should support multiple sites" do
      subject.parse(%w(title http://www.site.com/ --multi-site))
      expect(subject.spider).to be_multi_site
    end
  end

  context "#editor" do
    it "should create speaker" do
      subject.parse(%w(title http://site.com/))
      expect(subject.editor).not_to be_nil
      # defaults
    end
  end

  context "#speaker" do
    it "should create speaker" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.speaker.force).not_to be_truthy
    end

    # opts.on("-v", "--[no-]verbose", "Run verbosely")

    it "should set force" do
      subject.parse(%w(title http://site.com/ --force-audio))
      # defaults
      expect(subject.speaker.force).to be_truthy
    end
  end
end
