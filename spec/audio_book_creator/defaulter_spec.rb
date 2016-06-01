require 'spec_helper'

describe AudioBookCreator::Defaulter do
  # sample to use for settings
  let(:all_settings) do
    {
      "www.host.com" => {
        :title_path   => "h1.host",
        :body_path    => "div.host",
        :link_path    => "a.host",
        :chapter_path => "a.chapter.host",
      }
    }
  end

  let(:settings)    { {} }
  let(:page_def)    { AudioBookCreator::PageDef.new("h1.title", "div", "a.link", "a.chapter") }
  let(:book_def)    do
    AudioBookCreator::BookDef.new("the title", "author", "dir", %w(a b), true).tap do |bd|
      bd.urls = %w(http://www.host.com/)
    end
  end
  subject { described_class.new(page_def, book_def).tap { |d| d.settings = settings } }

  describe "#initialize" do
    it { expect(subject.page_def).to eq(page_def) }
    it { expect(subject.book_def).to eq(book_def) }
  end

  describe "#host" do
    it "supports empty url" do
      book_def.urls = %w()
      expect(subject.host).to be_nil
    end

    it { expect(subject.host).to eq("www.host.com") }
  end

  describe "#settings" do
    # clear out settings so Defaulter can actually set it up correctly
    before { subject.settings = nil }

    it "sets filename" do
      expect(subject.settings.filename).to eq("settings.db")
    end

    it "sets table_name" do
      expect(subject.settings.table_name).to eq("settings")
    end

    it "sets table_name" do
      expect(subject.settings.encode).to eq(true)
    end
  end

  # settings => page_defs
  describe "#load_unset_values" do
    it "skips on nil" do
      subject.settings = 1 # ensure this is not accessed (because host is empty)
      book_def.urls = []
      subject.load_unset_values
      expect_page_def("h1.title", "div", "a.link", "a.chapter")
    end

    it "skips unknown hosts" do
      subject.settings = {"host2.com" => {:title_path => "h1.host2"}}
      subject.load_unset_values
      expect_page_def("h1.title", "div", "a.link", "a.chapter")
    end

    it "uses a) hostname to b) set partial values" do
      subject.settings = {"www.host.com" => {:title_path => "h1.host"}}
      book_def.urls = %w(http://www.host.com/abc)
      subject.load_unset_values
      expect_page_def("h1.host", "div", "a.link", "a.chapter")
    end

    it "sets all values" do
      subject.settings = all_settings
      subject.load_unset_values
      expect_page_def("h1.host", "div.host", "a.host", "a.chapter.host")
    end
  end

  # page_defs => settings
  describe "#store" do
    let(:settings) { all_settings }
    let(:page_def) { AudioBookCreator::PageDef.new(nil, nil, nil, nil) }

    it "skips on empty url" do
      subject.settings = 1 # ensure this is not accessed (because host is empty)
      book_def.urls = []
      expect { subject.store }.not_to raise_error
    end

    context "with unknown host" do
      let(:settings) { {} }

      it "adds settings" do
        # no settings for this host
        page_def.title_path = "h1.changed"
        subject.store
        expect_settings("h1.changed")
      end
    end

    it "updates only overridden values" do
      page_def.title_path = "h1.changed"
      subject.store
      expect_settings("h1.changed", "div.host", "a.host", "a.chapter.host")
    end

    it "sets all values" do
      page_def.title_path   = "h1.changed"
      page_def.body_path    = "div.changed"
      page_def.link_path    = "a.changed"
      page_def.chapter_path = "a.chapter.changed"
      subject.store
      expect_settings("h1.changed", "div.changed", "a.changed", "a.chapter.changed")
    end
  end

  def expect_page_def(title_path, body_path, link_path, chapter_path)
    expect(page_def.title_path).to eq(title_path)
    expect(page_def.body_path).to eq(body_path)
    expect(page_def.link_path).to eq(link_path)
    expect(page_def.chapter_path).to eq(chapter_path)
  end

  def expect_settings(title_path = nil, body_path = nil, link_path = nil, chapter_path = nil)
    value = settings[subject.host]
    expect(value).not_to be_nil
    if title_path
      expect(value[:title_path]).to eq(title_path)
    else
      expect(value).not_to have_key(:title_path)
    end
    if body_path
      expect(value[:body_path]).to eq(body_path)
    else
      expect(value).not_to have_key(:body_path)
    end
    if link_path
      expect(value[:link_path]).to eq(link_path)
    else
      expect(value).not_to have_key(:link_path)
    end
    if chapter_path
      expect(value[:chapter_path]).to eq(chapter_path)
    else
      expect(value).not_to have_key(:chapter_path)
    end
  end
end
