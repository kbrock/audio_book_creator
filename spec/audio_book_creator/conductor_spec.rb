require 'spec_helper'

describe AudioBookCreator::Conductor do
  let(:page_def)    { AudioBookCreator::PageDef.new("h1.title", "div", "a.link", "a.chapter") }
  let(:book_def)    do
    AudioBookCreator::BookDef.new("the title", "author", "dir", %w(a b), true).tap do |bd|
      bd.urls = %w(http://www.host.com/ http://www.host.com/)
    end
  end
  let(:speaker_def) { AudioBookCreator::SpeakerDef.new }
  let(:surfer_def)  { AudioBookCreator::SurferDef.new(5, true) }
  subject           { described_class.new(page_def, book_def, speaker_def, surfer_def) }

  context "#initialize" do
    it { expect(subject.page_def).to    eq(page_def) }
    it { expect(subject.book_def).to    eq(book_def) }
    it { expect(subject.speaker_def).to eq(speaker_def) }
    it { expect(subject.surfer_def).to  eq(surfer_def) }
    it { expect(subject.page_def.invalid_urls).to  eq(subject.invalid_urls) }
  end

  describe "#page_cache" do
    it "sets filename" do
      expect(subject.page_cache.filename).to eq("pages.db")
    end

    it "sets table_name" do
      expect(subject.page_cache.table_name).to eq("pages")
    end

    it "sets table_name" do
      expect(subject.page_cache.encode).to eq(false)
    end
  end

  context "#web" do
    it "sets references" do
      expect(subject.web.max).to eq(subject.surfer_def.max)
    end
  end

  context "#cached_web" do
    it "sets references" do
      expect(subject.cached_web.cache).to eq(subject.page_cache)
      expect(subject.cached_web.main).to eq(subject.web)
      expect(subject.cached_web).to respond_to(:main)
    end
  end

  context "#invalid_urls" do
    it "sets references" do
      expect(subject.invalid_urls.host).to eq("www.host.com")
      expect(subject.page_def.invalid_urls.host).to eq("www.host.com")
      expect(subject.page_def.invalid_urls).to eq(subject.invalid_urls)
    end
  end

  context "#spider" do
    it "sets references" do
      expect(subject.spider.page_def).to eq(subject.page_def)
      expect(subject.spider.web).to eq(subject.cached_web)
    end
  end

  context "#editor" do
    it "sets references" do
      expect(subject.editor.page_def).to eq(subject.page_def)
      # needs to be an editor
      expect(subject.editor).to respond_to(:parse)
      # hack
      expect(subject.editor).not_to eq(subject)
    end
  end

  context "#speaker" do
    it "should create speaker" do
      expect(subject.speaker.speaker_def).to eq(subject.speaker_def)
      expect(subject.speaker.book_def).to eq(subject.book_def)
      expect(subject.speaker).to respond_to(:say)
    end
  end

  context "#binder" do
    it "should create a binder" do
      expect(subject.binder.book_def).to eq(subject.book_def)
      expect(subject.binder.speaker_def).to eq(subject.speaker_def)
      expect(subject.binder).to respond_to(:create)
    end
  end

  describe "#creator" do
    it "should create a book creator" do
      expect(subject.creator.spider).to  eq(subject.spider)
      expect(subject.creator.editor).to  eq(subject.editor)
      expect(subject.creator.speaker).to eq(subject.speaker)
      expect(subject.creator.binder).to  eq(subject.binder)
      expect(subject.creator).to respond_to(:create)
    end
  end

  describe "#outstanding" do
    it "should set outstanding" do
      expect(subject.outstanding).to eq(book_def.unique_urls)
    end
  end

  describe "#run" do
    it do
      expect(subject.creator).to receive(:create).with(subject.outstanding)
      subject.run
    end
  end
end
