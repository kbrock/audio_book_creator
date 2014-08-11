require 'spec_helper'

# NOTE: cli class is not in the path by default
#       it is only included by running the command
require 'audio_book_creator/cli'

describe AudioBookCreator::Cli do
  # this sidesteps creating a database file
  subject { described_class.new(database: ":memory:") }

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

  # in tests, we are stubbing this with ":memory:" so we don't create files
  it "should base database name upon title" do
    subject[:database] = nil
    subject.parse(%w(title http://site.com/))
    expect(subject[:database]).to eq("#{subject.base_dir}/pages.db")
  end

  # file sanitization is tested in audio_book_creator.spec
  context "#base_dir" do
    it "should derive base_dir from title" do
      subject.parse(%w(title http://www.site.com/))
      expect(subject.base_dir).to eq("title")
    end

    it "should support titles with spaces" do
      subject.parse(["title !for", "http://www.site.com/"])
      expect(subject.base_dir).to eq("title-for")
    end

    it "should support titles with extra stuff" do
      subject.parse(["title,for!", "http://www.site.com/"])
      expect(subject.base_dir).to eq("title-for")
    end

    it "should append truncation into the title" do
      subject.parse(%w(title http://www.site.com/ --max-p 22))
      expect(subject.base_dir).to eq("title.22")
    end
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
      subject.parse(%w(title http://site.com/))
      expect(File).to receive(:exist?).with(subject.base_dir).and_return(false)
      expect(FileUtils).to receive(:mkdir)
      subject.make_directory_structure
    end

    it "should not create base directory if it exists" do
      subject.parse(%w(title http://site.com/))
      expect(File).to receive(:exist?).with(subject.base_dir).and_return(true)
      expect(FileUtils).not_to receive(:mkdir)
      subject.make_directory_structure
    end
  end

  context "#page_cache" do
    it "should have databse based upon title" do
      subject.parse(%w(title http://site.com/))
      # NOTE: testing actual database filename calculation at top of spec
      expect(subject.page_cache.filename).to eq(subject[:database])
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
      expect(subject.spider.cache).to eq(subject.page_cache)
      expect(subject.spider.outstanding).to eq(%w(http://www.site.com/))
      # defaults
      expect(subject.spider.verbose).not_to be_truthy
      expect(subject.spider.max).to eq(10)
      expect(subject.spider.host_limit).to eq("www.site.com")
      expect(subject.spider).not_to be_multi_site
      # NOTE: not currently passed
      expect(subject.spider.ignore_bogus).not_to be_truthy
    end

    it "should be verbose" do
      subject.parse(%w(title http://www.site.com/ -v))
      # logging a url was added to the queue
      expect_any_instance_of(AudioBookCreator::Spider).to receive(:puts)
      expect(subject.spider.verbose).to be_truthy
    end

    it "should support link" do
      subject.parse(%w(title http://www.site.com/ --link a.next_page))
      expect(subject.spider.link_path).to eq("a.next_page")
    end

    it "should have no max" do
      subject.parse(%w(title http://www.site.com/ --no-max))
      expect(subject.spider.max).not_to be_truthy
    end

    it "should have a max" do
      subject.parse(%w(title http://www.site.com/ --max 20))
      expect(subject.spider.max).to eq(20)
    end

    it "should support multiple sites" do
      subject.parse(%w(title http://www.site.com/ --multi-site))
      expect(subject.spider).to be_multi_site
      expect(subject.spider.host_limit).to be_nil
    end
  end

  context "#editor" do
    it "should create editor" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.editor.title_path).to eq("h1")
      expect(subject.editor.body_path).to eq("p")
      expect(subject.editor.max_paragraphs).to be_nil
    end

    it "should support max paragraphs" do
      subject.parse(%w(title http://www.site.com/ --max-p 5))
      expect(subject.editor.max_paragraphs).to eq(5)
    end

    it "should support title" do
      subject.parse(%w(title http://www.site.com/ --title h1.big))
      expect(subject.editor.title_path).to eq("h1.big")
    end

    it "should support body" do
      subject.parse(%w(title http://www.site.com/ --body p.content))
      expect(subject.editor.body_path).to eq("p.content")
    end
  end

  context "#speaker" do
    it "should create speaker" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.speaker.base_dir).to eq(subject.base_dir)
      expect(subject.speaker.verbose).not_to be_truthy
      expect(subject.speaker.force).not_to be_truthy
      expect(subject.speaker.voice).to eq("Vicki")
      expect(subject.speaker.rate).to eq(320)
    end

    it "should set verbose" do
      subject.parse(%w(title http://site.com/ --verbose))
      expect(subject.speaker.verbose).to be_truthy
    end

    it "should set force" do
      subject.parse(%w(title http://site.com/ --force-audio))
      expect(subject.speaker.force).to be_truthy
    end

    it "should set voice" do
      subject.parse(%w(title http://site.com/ --voice Serena))
      expect(subject.speaker.voice).to eq("Serena")
    end

    it "should set rate" do
      subject.parse(%w(title http://site.com/ --rate 200))
      expect(subject.speaker.rate).to eq(200)
    end

  end

  context "#binder" do
    it "should create a binder" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.binder.base_dir).to eq(subject.base_dir)
      expect(subject.binder.title).to eq("title")
      expect(subject.binder.verbose).not_to be_truthy
      expect(subject.binder.force).not_to be_truthy
      # NOTE: not currently passed
      expect(subject.binder.author).to eq("Vicki")
      expect(subject.binder.channels).to eq(1)
      expect(subject.binder.max_hours).to eq(7)
      expect(subject.binder.bit_rate).to eq(32)
      expect(subject.binder.sample_rate).to eq(22_050)
    end

    it "should set verbose" do
      subject.parse(%w(title http://site.com/ --verbose))
      expect(subject.binder.verbose).to be_truthy
    end

    it "should set force" do
      subject.parse(%w(title http://site.com/ --force-audio))
      expect(subject.binder.force).to be_truthy
    end

    it "should set author" do
      subject.parse(%w(title http://site.com/ --force-audio))
      expect(subject.binder.force).to be_truthy
    end

    it "should set force" do
      subject.parse(%w(title http://site.com/ --force-audio))
      expect(subject.binder.force).to be_truthy
    end
  end

  # this is kinda testing the implementation
  context "#run" do
    it "should call all the constructors and components" do
      subject.parse(%w(title http://site.com/))
      # make_directory_structure:
      expect(File).to receive(:exist?).with("title").and_return(true)
      # spider:
      expect_spider_to_visit_page(subject.spider, "http://site.com/", "<h1>title</h1>", "<p>contents</p>")
      # speaker:
      expect(File).to receive(:exist?).with("title/chapter01.txt").and_return(true)
      expect(File).to receive(:exist?).with("title/chapter01.m4a").and_return(true)
      # binder
      expect(File).to receive(:exist?).with("title.m4b").and_return(true)

      subject.run
    end
  end
end
