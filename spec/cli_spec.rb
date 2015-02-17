require 'spec_helper'
require 'uri'
require 'logger'
# NOTE: cli class is not in the path by default
#       it is only included by running the command
require 'audio_book_creator/cli'

describe AudioBookCreator::Cli do
  # this sidesteps creating a database file
  subject { described_class.new.tap { |s| s.database = ":memory:" } }

  # this is testing the spec more than the objects
  # since we didn't want to create the cache file, this is necessary
  context "database name" do
    it "defaults to test override" do
      expect(subject.database).to eq(":memory:")
    end

    it "creates database with overriden value" do
      subject.parse(%w(http://site.com/title))
      expect(subject.surfer_def.cache_filename).to eq(":memory:")
      expect(subject.page_cache.filename).to eq(subject.surfer_def.cache_filename)
    end

    it "creates database based upon title" do
      subject.database = nil # removes the default test name of :memory:
      subject.parse(%w(http://site.com/title))
      expect(subject.surfer_def.cache_filename).to eq("title/pages.db")
      expect(subject.page_cache.filename).to eq(subject.surfer_def.cache_filename)
      subject.page_cache
    end
  end

  context "with no arguments" do
    it "displays an error" do
      expect($stdout).to receive(:puts).with(/url/, /Usage.*title/)
      expect(subject).to receive(:exit).with(2).and_raise("exited")
      expect { subject.parse([]) }.to raise_error("exited")
    end
  end

  context "with one argument" do
    it "assigns title and url" do
      subject.parse(%w(http://site.com/title))
      expect(subject[:title]).to eq("title")
      expect(subject[:urls]).to eq(%w(http://site.com/title))
    end

    it "defaults to error" do
      subject.parse(%w(http://site.com/title))
      subject.set_logger
      expect(AudioBookCreator.logger.level).to eq(Logger::WARN)
    end
  end

  context "with title and url" do
    it "assigns title and url" do
      subject.parse(%w(title http://site.com/))
      expect(subject[:title]).to eq("title")
      expect(subject[:urls]).to eq(%w(http://site.com/))
    end
  end

  context "with multiple urls" do
    it "assigns title and url" do
      subject.parse(%w(http://site.com/title http://site.com/title2))
      expect(subject[:title]).to eq("title")
      expect(subject[:urls]).to eq(%w(http://site.com/title http://site.com/title2))
    end
  end

  context "with title and multiple urls" do
    it "has multiple urls" do
      subject.parse(%w(title http://site.com/page1 http://site.com/page2))
      expect(subject[:title]).to eq("title")
      expect(subject[:urls]).to eq(%w(http://site.com/page1 http://site.com/page2))
    end
  end

  context "with verbose" do
    it "defaults to warning logging" do
      subject.parse(%w(http://site.com/title --verbose))
      subject.set_logger
      expect(AudioBookCreator.logger.level).to eq(Logger::INFO)
    end

    it "defaults to warning" do
      subject.parse(%w(http://site.com/title -v))
      subject.set_logger
      expect(AudioBookCreator.logger.level).to eq(Logger::INFO)
    end
  end


  context "#parse" do
    # actual cli calls subject.parse.run, so it needs to chain
    it { expect(subject.parse(%w(http://site.com/title))).to eq(subject) }
  end

  # parameters

  context "#defaults" do
    it "should default values" do
      # NOTE: calling with no constructor
      pristine = described_class.new
      expect(pristine[:max]).to eq(10)
      expect(pristine[:title_path]).to eq("h1")
      expect(pristine[:body_path]).to eq("p")
      expect(pristine[:link_path]).to eq("a")
    end
  end

  # file sanitization is tested in audio_book_creator.spec
  context "#base_dir" do
    it "should derive base_dir from title" do
      subject.parse(%w(title http://site.com/))
      expect(subject.book_def.base_dir).to eq("title")
    end

    it "should support titles with spaces" do
      subject.parse(["title !for", "http://site.com/"])
      expect(subject.book_def.base_dir).to eq("title-for")
    end

    it "should support titles with extra stuff" do
      subject.parse(["title,for!", "http://site.com/"])
      expect(subject.book_def.base_dir).to eq("title-for")
    end

    it "should append truncation into the title" do
      subject.parse(%w(title http://site.com/ --max-p 22))
      expect(subject.book_def.base_dir).to eq("title.22")
    end

    it "should override basedir" do
      subject.parse(%w(title http://site.com/ --base-dir dir))
      expect(subject.book_def.base_dir).to eq("dir")
    end
  end

  context "with version" do
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
      "-A" => "Load book into itunes",
      "--itunes" => "Load book into itunes",
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

  context "max param" do
    it "should default to 10" do
      subject.parse(%w(http://site.com/title))
      expect(subject.web.max).to eq(10)
    end

    it "should have a max" do
      subject.parse(%w(http://site.com/title --max 20))
      expect(subject.web.max).to eq(20)
    end

    it "should have no max" do
      subject.parse(%w(http://site.com/title --no-max))
      expect(subject.web.max).not_to be_truthy
    end
  end

  context "#page_cache" do
    it "should have database based upon title" do
      subject.parse(%w(http://site.com/title))
      # defaults
      expect(subject.page_cache.filename).to eq(subject.surfer_def.cache_filename)
    end
  end

  context "#outstanding" do
    it "sets url" do
      subject.parse(%w(http://site.com/title))
      expect(subject.outstanding.shift.to_s).to eq("http://site.com/title")
      expect(subject.outstanding.shift).to be_nil
    end

    it "should not visit same url twice" do
      subject.parse(%w(http://site.com/page1 http://site.com/page2 http://site.com/page1))
      expect(subject.outstanding.shift.to_s).to eq("http://site.com/page1")
      expect(subject.outstanding.shift.to_s).to eq("http://site.com/page2")
      expect(subject.outstanding.shift).to be_nil
    end
  end

  context "#spider" do
    it "sets references" do
      subject.parse(%w(http://site.com/title))
      expect(subject.spider.page_def).to eq(subject.page_def)
      expect(subject.spider.web).to eq(subject.cached_web)
      expect(subject.spider.invalid_urls).to eq(subject.invalid_urls)
    end
  end

  context "#invalid_urls" do
    it "sets host for invalid urls" do
      subject.parse(%w(http://site.com/title))
      expect(subject.invalid_urls.host).to eq("site.com")
    end
  end

  context "#page_def" do
    it "should create page_def" do
      subject.parse(%w(http://site.com/title))
      # defaults
      expect(subject.page_def.title_path).to eq("h1")
      expect(subject.page_def.body_path).to eq("p")
      expect(subject.page_def.link_path).to eq("a")
      expect(subject.page_def.max_paragraphs).to be_nil
    end

    it "should support max paragraphs" do
      subject.parse(%w(http://site.com/title --max-p 5))
      expect(subject.page_def.max_paragraphs).to eq(5)
    end

    it "should support title" do
      subject.parse(%w(http://site.com/title --title h1.big))
      expect(subject.page_def.title_path).to eq("h1.big")
    end

    it "should support body" do
      subject.parse(%w(http://site.com/title --body p.content))
      expect(subject.page_def.body_path).to eq("p.content")
    end

    it "should support link" do
      subject.parse(%w(http://site.com/title --link a.next_page))
      expect(subject.page_def.link_path).to eq("a.next_page")
    end
  end

  context "#book_def" do
    it "should create book_def" do
      subject.parse(%w(http://site.com/title))
      # defaults
      expect(subject.book_def.base_dir).to eq("title")
      expect(subject.book_def.title).to eq("title")
      expect(subject.book_def.author).to eq("Vicki")
      expect(subject.book_def.itunes).not_to be_truthy
    end

    it "should leverage max paragraphs" do
      subject.parse(%w(http://site.com/title --max-p 5))
      expect(subject.book_def.base_dir).to eq("title.5")
    end

    it "should support basedir" do
      subject.parse(%w(http://site.com/title --base-dir dir))
      # defaults
      expect(subject.book_def.base_dir).to eq("dir")
      expect(subject.book_def.title).to eq("title")
    end

    it "should set itunes" do
      subject.parse(%w(http://site.com/title -A))
      expect(subject.book_def.itunes).to be_truthy
    end
  end

  context "#speaker_def" do
    it "should default" do
      subject.parse(%w(http://site.com/title))
      expect(subject.speaker_def.voice).to eq("Vicki")
      expect(subject.speaker_def.rate).to eq(280)


      expect(subject.speaker_def.channels).to eq(1)
      expect(subject.speaker_def.max_hours).to eq(7)
      expect(subject.speaker_def.bit_rate).to eq(32)
      expect(subject.speaker_def.sample_rate).to eq(22_050)
      expect(subject.speaker_def.regen_audio).not_to be_truthy
    end

    it "should set voice" do
      subject.parse(%w(http://site.com/title --voice Serena))
      expect(subject.speaker_def.voice).to eq("Serena")
    end

    it "should set rate" do
      subject.parse(%w(http://site.com/title --rate 200))
      expect(subject.speaker_def.rate).to eq(200)
    end

    it "should set force" do
      subject.parse(%w(http://site.com/title --force-audio))
      expect(subject.speaker_def.regen_audio).to be_truthy
    end
  end

  context "#surfer_def" do
    it "assigns cache_filename" do
      subject.parse(%w(http://site.com/title))
      expect(subject.surfer_def.cache_filename).to eq(subject.database)
    end
  end

  context "#cached_web" do
    it "default" do
      subject.parse(%w(http://site.com/title))
      expect(subject.cached_web.cache).to eq(subject.page_cache)
      expect(subject.cached_web.main).to eq(subject.web)
      expect(subject.cached_web).to respond_to(:main)
    end
  end

  context "#editor" do
    it "should create editor" do
      subject.parse(%w(http://site.com/title))
      # defaults
      expect(subject.editor.page_def).to eq(subject.page_def)
      # needs to be an editor
      expect(subject.editor).to respond_to(:parse)
      # hack
      expect(subject.editor).not_to eq(subject)
    end
  end

  context "#speaker" do
    it "should create speaker" do
      subject.parse(%w(http://site.com/title))
      # defaults
      expect(subject.speaker.speaker_def).to eq(subject.speaker_def)
      expect(subject.speaker.book_def).to eq(subject.book_def)
      expect(subject.speaker_def.regen_audio).not_to be_truthy
      expect(subject.speaker).to respond_to(:say)
    end

    it "should set force" do
      subject.parse(%w(http://site.com/title --force-audio))
      expect(subject.speaker_def.regen_audio).to be_truthy
    end
  end

  context "#binder" do
    it "should create a binder" do
      subject.parse(%w(http://site.com/title))
      # defaults
      expect(subject.binder.book_def).to eq(subject.book_def)
      expect(subject.binder.speaker_def).to eq(subject.speaker_def)
      # NOTE: not currently passed
    end
  end

  describe "#creator" do
    it "should create a book creator" do
      subject.parse(%w(http://site.com/title))
      expect(subject.creator.spider).to  eq(subject.spider)
      expect(subject.creator.editor).to  eq(subject.editor)
      expect(subject.creator.speaker).to eq(subject.speaker)
      expect(subject.creator.binder).to  eq(subject.binder)
      expect(subject.creator).to respond_to(:create)
    end
  end

  describe "#run" do
    it "should call book creator" do
      subject.parse(%w(http://site.com/title))
      creator = double(:creator)
      expect(creator).to receive(:create).with(subject.outstanding).and_return("YAY")
      expect(subject).to receive(:set_logger)
      expect(subject).to receive(:creator).and_return(creator)
      expect(subject.run).to eq("YAY")
    end
  end
end
