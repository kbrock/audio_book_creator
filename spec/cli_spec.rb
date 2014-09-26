require 'spec_helper'
require 'uri'
require 'logger'
# NOTE: cli class is not in the path by default
#       it is only included by running the command
require 'audio_book_creator/cli'

describe AudioBookCreator::Cli do
  # this sidesteps creating a database file
  subject { described_class.new(database: ":memory:") }

  context "basic arguments" do
    it "should treat first arguments as a url" do
      subject.parse(%w(title http://site.com/))
      expect(subject[:title]).to eq("title")
      expect(subject[:urls]).to eq(%w(http://site.com/))
    end

    it "should support multiple urls" do
      subject.parse(%w(title http://site.com/page1 http://site.com/page2))
      expect(subject[:title]).to eq("title")
      expect(subject[:urls]).to eq(%w(http://site.com/page1 http://site.com/page2))
    end

    it "should require 2 parameters" do
      expect($stdout).to receive(:puts).with(/url/, /Usage.*title/)
      expect(subject).to receive(:exit).with(2).and_raise("exited")
      expect { subject.parse(%w(title_only)) }.to raise_error("exited")
    end
  end

  context "database name" do
    it "defaults to test override" do
      expect(subject[:database]).to eq(":memory:")
    end

    it "creates database with overriden value" do
      subject.parse(%w(title http://site.com/))
      expect(subject.book_def.cache_filename).to eq(":memory:")
      expect(subject.page_cache.filename).to eq(subject.book_def.cache_filename)
    end

    it "creates database based upon title" do
      subject[:database] = nil # removes the default test name of :memory:
      subject.parse(%w(title http://site.com/))
      expect(subject.book_def.cache_filename).to eq("title/pages.db")
      expect(subject.page_cache.filename).to eq(subject.book_def.cache_filename)
      subject.page_cache
    end
  end

  context "#defaults" do
    it "should default values" do
      # NOTE: calling with no constructor
      pristine = described_class.new
      expect(pristine[:max]).to eq(10)
      expect(pristine[:title_path]).to eq("h1")
      expect(pristine[:body_path]).to eq("p")
      expect(pristine[:link_path]).to eq("a")
    end

    it "should not overwrite constructor values with defaults" do
      expect(described_class.new(max: 20)[:max]).to eq(20)
    end
  end

  # file sanitization is tested in audio_book_creator.spec
  context "#base_dir" do
    it "should derive base_dir from title" do
      subject.parse(%w(title http://www.site.com/))
      expect(subject.book_def.base_dir).to eq("title")
    end

    it "should support titles with spaces" do
      subject.parse(["title !for", "http://www.site.com/"])
      expect(subject.book_def.base_dir).to eq("title-for")
    end

    it "should support titles with extra stuff" do
      subject.parse(["title,for!", "http://www.site.com/"])
      expect(subject.book_def.base_dir).to eq("title-for")
    end

    it "should append truncation into the title" do
      subject.parse(%w(title http://www.site.com/ --max-p 22))
      expect(subject.book_def.base_dir).to eq("title.22")
    end

    it "should override basedir" do
      subject.parse(%w(title http://www.site.com/ --base-dir dir))
      expect(subject.book_def.base_dir).to eq("dir")
    end
  end

  context "#version" do
    it "should provide version" do
      expect($stdout).to receive(:puts).with(/audio_book_creator #{AudioBookCreator::VERSION}/)
      expect { subject.parse(%w(--version)) }.to raise_error(SystemExit)
    end
  end

  context "#help" do
    {
      "-v" => "Run verbosely",
      "--verbose" => "Run verbosely",
      "--title" => "Title css",
      "--body" => "Content css",
      "--link" => "Follow css",
      "--no-max" => "Don't limit the number of pages to visit",
      "--max" => "Maximum number of pages to visit",
      "--max-p" => "Max paragraphs per chapter",
      "--force-audio" => "Regerate the audio",
      "--force-html" => "Regerate the audio",
      "--rate" => "Set words per minute",
      "--voice" => "Set speaker voice",
      "--base-dir" => "Directory to hold files",
    }.each do |switch, text|
      it "should display #{text} for #{switch} option" do
        expect($stdout).to receive(:puts).with(/#{switch}.*#{text}/)
        expect { subject.parse(%w(--help)) }.to raise_error(SystemExit)
      end
    end

    it "should provide help" do
      expect($stdout).to receive(:puts).with(/Usage/)
      #expect(subject).to receive(:exit).with(1).and_raise("exited")
      expect { subject.parse(%w(--help)) }.to raise_error(SystemExit)
    end

    it "should provide help (with short option)" do
      expect($stdout).to receive(:puts).with(/Usage/)
      expect { subject.parse(%w(-h)) }.to raise_error(SystemExit)
    end
  end

  context "#set_logger" do
    it "should default to error" do
      subject.parse(%w(title http://site.com/))
      subject.set_logger
      expect(AudioBookCreator.logger.level).to eq(Logger::WARN)
    end

    it "should warn" do
      subject.parse(%w(title http://site.com/ --verbose))
      subject.set_logger
      expect(AudioBookCreator.logger.level).to eq(Logger::INFO)
    end

    it "should warn" do
      subject.parse(%w(title http://site.com/ -v))
      subject.set_logger
      expect(AudioBookCreator.logger.level).to eq(Logger::INFO)
    end
  end

  context "#make_directory_structure" do
    it "should create base directory" do
      subject.parse(%w(title http://site.com/))
      expect(File).to receive(:exist?).with(subject.book_def.base_dir).and_return(false)
      expect(FileUtils).to receive(:mkdir).with(subject.book_def.base_dir)
      subject.make_directory_structure
    end

    it "should not create base directory if it exists" do
      subject.parse(%w(title http://site.com/))
      expect(File).to receive(:exist?).with(subject.book_def.base_dir).and_return(true)
      expect(FileUtils).not_to receive(:mkdir)
      subject.make_directory_structure
    end
  end

  context "max param" do
    it "should default to 10" do
      subject.parse(%w(title http://www.site.com/))
      expect(subject.web.max).to eq(10)
    end

    it "should have a max" do
      subject.parse(%w(title http://www.site.com/ --max 20))
      expect(subject.web.max).to eq(20)
    end

    it "should have no max" do
      subject.parse(%w(title http://www.site.com/ --no-max))
      expect(subject.web.max).not_to be_truthy
    end
  end

  context "#page_cache" do
    it "should have databse based upon title" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.page_cache.force).not_to be_truthy
    end

    it "should support force" do
      subject.parse(%w(title http://site.com/ --force-html))
      expect(subject.page_cache.force).to be_truthy
    end
  end

  context "#outstanding" do
    it "sets url" do
      subject.parse(%w(title http://www.site.com/))
      expect(subject.outstanding.shift).to eq(uri("http://www.site.com/"))
      expect(subject.outstanding.shift).to be_nil
    end

    it "should not visit same url twice" do
      subject.parse(%w(title http://site.com/page1 http://site.com/page2 http://site.com/page1))
      expect(subject.outstanding.shift).to eq(uri("http://site.com/page1"))
      expect(subject.outstanding.shift).to eq(uri("http://site.com/page2"))
      expect(subject.outstanding.shift).to be_nil
    end
  end

  context "#spider" do
    it "sets references" do
      subject.parse(%w(title http://www.site.com/))
      expect(subject.spider.web).to eq(subject.cached_web)
    end
  end

  context "#page_def" do
    it "should create page_def" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.page_def.title_path).to eq("h1")
      expect(subject.page_def.body_path).to eq("p")
      expect(subject.page_def.link_path).to eq("a")
      expect(subject.page_def.max_paragraphs).to be_nil
    end

    it "should support max paragraphs" do
      subject.parse(%w(title http://www.site.com/ --max-p 5))
      expect(subject.page_def.max_paragraphs).to eq(5)
    end

    it "should support title" do
      subject.parse(%w(title http://www.site.com/ --title h1.big))
      expect(subject.page_def.title_path).to eq("h1.big")
    end

    it "should support body" do
      subject.parse(%w(title http://www.site.com/ --body p.content))
      expect(subject.page_def.body_path).to eq("p.content")
    end

    it "should support link" do
      subject.parse(%w(title http://www.site.com/ --link a.next_page))
      expect(subject.page_def.link_path).to eq("a.next_page")
    end
  end

  context "#book_def" do
    it "should create book_def" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.book_def.base_dir).to eq("title")
      expect(subject.book_def.title).to eq("title")
      expect(subject.book_def.author).to eq("Vicki")
      expect(subject.book_def.voice).to eq("Vicki")
      expect(subject.book_def.rate).to eq(280)
    end

    it "should support basedir" do
      subject.parse(%w(title http://site.com/ --base-dir dir))
      # defaults
      expect(subject.book_def.base_dir).to eq("dir")
      expect(subject.book_def.title).to eq("title")
    end

    it "should set voice" do
      subject.parse(%w(title http://site.com/ --voice Serena))
      expect(subject.book_def.voice).to eq("Serena")
    end

    it "should set rate" do
      subject.parse(%w(title http://site.com/ --rate 200))
      expect(subject.book_def.rate).to eq(200)
    end
  end

  context "#editor" do
    it "should create editor" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.editor.page_def).to eq(subject.page_def)
    end
  end

  context "#speaker" do
    it "should create speaker" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.speaker.book_def).to eq(subject.book_def)
      expect(subject.speaker.force).not_to be_truthy
    end

    it "should set force" do
      subject.parse(%w(title http://site.com/ --force-audio))
      expect(subject.speaker.force).to be_truthy
    end
  end

  context "#binder" do
    it "should create a binder" do
      subject.parse(%w(title http://site.com/))
      # defaults
      expect(subject.binder.force).not_to be_truthy
      # NOTE: not currently passed
      expect(subject.binder.channels).to eq(1)
      expect(subject.binder.max_hours).to eq(7)
      expect(subject.binder.bit_rate).to eq(32)
      expect(subject.binder.sample_rate).to eq(22_050)
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
      # make_directory_structure:
      expect(File).to receive(:exist?).with("title").and_return(true)
      # spider:
      expect_visit_page("http://site.com/", "<h1>title</h1>", "<p>contents</p>")
      # speaker:
      expect(File).to receive(:exist?).with("title/chapter01.txt").and_return(true)
      expect(File).to receive(:exist?).with("title/chapter01.m4a").and_return(true)
      # binder
      expect(File).to receive(:exist?).with("title.m4b").and_return(true)
      # chain parse and run to mimic bin/audio_book_creator
      subject.parse(%w(title http://site.com/ -v)).run
      expect(AudioBookCreator.logger.level).to eq(Logger::INFO)
    end
  end

  private

  # NOTE: this uses any_instance because we don't want to instantiate anything
  # could assign web and use a double instead
  def expect_visit_page(url, *args)
    url = site(url)
    expect_any_instance_of(AudioBookCreator::Web).to receive(:[])
      .with(url).and_return(page(url, *args))
  end
end
