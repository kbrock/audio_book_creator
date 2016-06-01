require 'spec_helper'
# NOTE: cli class is not in the path by default
#       it is only included by running the command
require 'audio_book_creator/cli'

describe AudioBookCreator::Cli do
  # this sidesteps creating a database file
  subject { described_class.new }
  let(:minimal_args) { %w(http://site.com/title) }

  describe "#parse", "with no arguments" do
    it "displays an error" do
      expect($stdout).to receive(:puts).with(/url/, /Usage.*title/)
      expect(subject).to receive(:exit).with(2).and_raise("exited")
      expect { subject.parse([]) }.to raise_error("exited")
    end
  end

  describe "#parse" do
    # not really part of this spec
    it "defaults to non verbose" do
      subject.parse(minimal_args)
      expect(AudioBookCreator.logger.level).to eq(Logger::WARN)
    end

    it "sets to info" do
      subject.parse(%w(http://site.com/title --no-verbose))
      expect(AudioBookCreator.logger.level).to eq(Logger::WARN)
    end

    context "with verbose" do
      it "sets to info" do
        subject.parse(%w(http://site.com/title --verbose))
        expect(AudioBookCreator.logger.level).to eq(Logger::INFO)
      end

      it "sets to info (abbreviated)" do
        subject.parse(%w(http://site.com/title -v))
        expect(AudioBookCreator.logger.level).to eq(Logger::INFO)
      end
    end

    # actual cli calls subject.parse.run, so it needs to chain
    it "can chain" do
      expect(subject.parse(minimal_args)).to eq(subject)
    end

    it "provides usage" do
      expect($stdout).to receive(:puts).with(/Usage: audio_book_creator.*\[title\] url/)
      expect { subject.parse(%w(--help)) }.to raise_error(SystemExit)
    end

    it "provides version" do
      expect($stdout).to receive(:puts).with(/audio_book_creator #{AudioBookCreator::VERSION}/)
      expect { subject.parse(%w(--version)) }.to raise_error(SystemExit)
    end

    {
      "-v" => "Run verbosely",
      "--verbose" => "Run verbosely",
      "--default" => "Set these parameters as default for this url regular expression",
      "--skip-defaults" => "Skip using defaults",
      "--title" => "Title css",
      "--body" => "Content css",
      "--link" => "Next Page css",
      "--chapter" => "Next Chapter css",
      "--no-max" => "Don't limit the number of pages to visit",
      "--max" => "Maximum number of pages to visit",
      "--force-audio" => "Regerate the audio",
      "--force-html" => "Regerate the audio",
      "--rate" => "Set words per minute",
      "--voice" => "Set speaker voice",
      "--base-dir" => "Directory to hold files",
      "-A" => "Load book into itunes",
      "--[no-]itunes" => "Load book into itunes",
    }.each do |switch, text|
      it "should display #{text} for #{switch} option" do
        expect($stdout).to receive(:puts).with(/#{Regexp.escape(switch)}.*#{text}/)
        expect { subject.parse(%w(--help)) }.to raise_error(SystemExit)
      end
    end

    it "should provide help" do
      expect($stdout).to receive(:puts).with(/Usage/)
      expect { subject.parse(%w(--help)) }.to raise_error(SystemExit)
    end

    it "should provide help (with short option)" do
      expect($stdout).to receive(:puts).with(/Usage/)
      expect { subject.parse(%w(-h)) }.to raise_error(SystemExit)
    end
  end

  describe "#parse", "#set_defaults" do
    it "defaults to no" do
      subject.parse(minimal_args)
      expect(subject.set_defaults).to be_falsey
    end

    it "sets to true" do
      subject.parse(%w(http://site.com/title --default))
      expect(subject.set_defaults).to eq(true)
    end
  end

  describe "#parse", "#skip_defaults" do
    it "defaults to no" do
      subject.parse(minimal_args)
      expect(subject.skip_defaults).to be_falsey
    end

    it "sets to true" do
      subject.parse(%w(http://site.com/title --skip-defaults))
      expect(subject.skip_defaults).to eq(true)
    end
  end

  describe "#parse", "#page_def" do
    it "#title" do
      subject.parse(%w(http://site.com/title --title h1.big))
      expect(subject.page_def.title_path).to eq("h1.big")
    end

    it "#body_path" do
      subject.parse(%w(http://site.com/title --body p.content))
      expect(subject.page_def.body_path).to eq("p.content")
    end

    it "#link_path" do
      subject.parse(%w(http://site.com/title --link a.next_page))
      expect(subject.page_def.link_path).to eq("a.next_page")
    end

    it "#chapter_path" do
      subject.parse(%w(http://site.com/title --chapter a.chapter))
      expect(subject.page_def.chapter_path).to eq("a.chapter")
    end
  end

  context "#parse", "#book_def" do
    it "should create book_def" do
      subject.parse(minimal_args)
      # defaults
      expect(subject.book_def.base_dir).to eq("title")
      expect(subject.book_def.title).to eq("title")
      #expect(subject.book_def.author).to eq("Vicki")
      #expect(subject.book_def.itunes).not_to be_truthy
    end

    # MOVE to book_def
    it "should support basedir" do
      subject.parse(%w(http://site.com/title --base-dir dir))
      # defaults
      expect(subject.book_def.base_dir).to eq("dir")
      expect(subject.book_def.title).to eq("title")
    end

    it "should set itunes" do
      subject.parse(%w(http://site.com/title -A))
      expect(subject.book_def.itunes).to be_truthy

      subject.parse(%w(http://site.com/title --itunes))
      expect(subject.book_def.itunes).to be_truthy
    end

    it "should unset itunes" do
      subject.parse(%w(http://site.com/title --no-itunes))
      expect(subject.book_def.itunes).to be_falsy
    end

    it "should pass all urls to book_def" do
      subject.parse(%w(http://site.com/title http://site.com/title http://site.com/title2))
      expect(subject.book_def.urls).to eq(%w(http://site.com/title http://site.com/title http://site.com/title2))
    end

    describe "#title #urls" do
      context "with url" do
        it "assigns url abbreviation as title" do
          subject.parse(minimal_args)
          expect(subject.book_def.title).to eq("title")
          expect(subject.book_def.urls).to eq(minimal_args)
        end
      end

      context "with title and url" do
        it "assigns title and url" do
          subject.parse(%w(title http://site.com/))
          expect(subject.book_def.title).to eq("title")
          expect(subject.book_def.urls).to eq(%w(http://site.com/))
        end
      end

      context "with multiple urls" do
        it "assigns title and url" do
          subject.parse(%w(http://site.com/title http://site.com/title2))
          expect(subject.book_def.title).to eq("title")
          expect(subject.book_def.urls).to eq(%w(http://site.com/title http://site.com/title2))
        end
      end

      context "with title and multiple urls" do
        it "has multiple urls" do
          subject.parse(%w(title http://site.com/page1 http://site.com/page2))
          expect(subject.book_def.title).to eq("title")
          expect(subject.book_def.urls).to eq(%w(http://site.com/page1 http://site.com/page2))
        end
      end
    end

    # NOTE: file sanitization is tested in audio_book_creator.spec
    describe "#base_dir" do
      # MOVE to book_def
      it "should support titles with spaces" do
        subject.parse(["title !for", "http://site.com/"])
        expect(subject.book_def.base_dir).to eq("title-for")
      end

      it "should override basedir" do
        subject.parse(%w(title http://site.com/ --base-dir dir))
        expect(subject.book_def.base_dir).to eq("dir")
      end
    end
  end

  describe "#parse", "#speaker_def" do
    it "should default" do
      subject.parse(minimal_args)
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

  describe "#parse", "#surfer_def" do
    it "defaults" do
      subject.parse(minimal_args)
    end

    it "sets host to first url" do
      subject.parse(%w(http://site.com/page1 http://site2.com/page2))
      expect(subject.surfer_def.host).to eq("http://site.com/page1")
    end

    context "#max" do
      it "sets" do
        subject.parse(%w(http://site.com/title --max 20))
        expect(subject.surfer_def.max).to eq(20)
      end

      it "unsets" do
        subject.parse(%w(http://site.com/title --max 20 --no-max))
        expect(subject.surfer_def.max).not_to be_truthy
      end
    end

    context "#regen_html" do
      it "sets" do
        subject.parse(%w(http://site.com/title --force-html))
        expect(subject.surfer_def.regen_html).to be_truthy
      end
    end
  end

  describe "#conductor" do
    it "should create a conductor" do
      subject.parse(minimal_args)
      expect(subject.conductor.page_def).to eq(subject.page_def)
      expect(subject.conductor.book_def).to eq(subject.book_def)
      expect(subject.conductor.speaker_def).to eq(subject.speaker_def)
      expect(subject.conductor.surfer_def).to eq(subject.surfer_def)
      expect(subject.conductor).to respond_to(:run)
      # this makes it not just look like the cli
      expect(subject.conductor).to respond_to(:spider)
    end
  end

  describe "#defaulter" do
    it "creates a defaulter" do
      subject.parse(minimal_args)
      expect(subject.defaulter.page_def).to eq(subject.page_def)
      expect(subject.defaulter.book_def).to eq(subject.book_def)
      expect(subject.defaulter).to respond_to(:store)
    end
  end

  describe "#run" do
    it "call book conductor and loads from settings" do
      subject.parse(minimal_args)
      stub_component(:conductor) { |c| expect(c).to receive(:run).and_return("YAY") }
      stub_component(:defaulter) { |d| expect(d).to receive(:load_unset_values) }
      expect(subject.run).to eq("YAY")
    end

    it "call book conductor and loads from settings" do
      subject.parse(minimal_args)
      subject.skip_defaults = true
      stub_component(:conductor) { |c| expect(c).to receive(:run).and_return("YAY") }
      expect(subject).not_to receive(:defaulter)
      expect(subject.run).to eq("YAY")
    end

    it "stores settings" do
      subject.parse(minimal_args)
      subject.set_defaults = true
      stub_component(:defaulter) { |d| expect(d).to receive(:store) }
      subject.run
    end
  end

  def stub_component(name, &block)
    dbl = double(name)
    yield(dbl)
    expect(subject).to receive(name).and_return(dbl)
  end
end
