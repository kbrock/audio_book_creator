require 'spec_helper'

describe AudioBookCreator::BookCreator do

  # this is kinda testing the implementation
  context "#run" do
    let(:spider)  { double(:spider) }
    let(:editor)  { double(:editor) }
    let(:speaker) { double(:speaker) }
    let(:binder)  { double(:binder) }

    subject { described_class.new(spider, editor, speaker, binder) }

    it "should call all the constructors and components" do
      outstanding = ["http://site.com/"]
      page_contents = [page("title1","contents1"), page("title2","contents2")]
      web_page_contents = page_contents.map { |p| AudioBookCreator::WebPage.new('', p) }
      chapters = [
        chapter("contents1", "title1", 1),
        chapter("contents2", "title2", 2)
      ]
      spoken_chapters = [
        spoken_chapter("title1", "dir/chapter01.m4a"),
        spoken_chapter("title2", "dir/chapter02.m4a")
      ]
      expect(speaker).to receive(:make_directory_structure)
      expect(spider).to receive(:run).with(outstanding).and_return(page_contents)
      expect(editor).to receive(:parse).with(web_page_contents).and_return(chapters)
      expect(speaker).to receive(:say).with(chapters.first).and_return(spoken_chapters.first)
      expect(speaker).to receive(:say).with(chapters.last).and_return(spoken_chapters.last)
      expect(binder).to receive(:create).with(spoken_chapters)

      subject.create(outstanding)
    end
  end

  # taken from cli
  # context "real object" do
  #   it "spiders the web" do
  #     # spider:
  #     expect_visit_page("http://site.com/", "<h1>title</h1>", "<p>contents</p>")
  #     # speaker:
  #     expect(File).to receive(:exist?).with("title").and_return(true)
  #     expect(File).to receive(:exist?).with("title/chapter01.txt").and_return(true)
  #     expect(File).to receive(:exist?).with("title/chapter01.m4a").and_return(true)
  #     # binder
  #     expect(File).to receive(:exist?).with("title.m4b").and_return(true)
  #     # chain parse and run to mimic bin/audio_book_creator
  #     subject.parse(%w(title http://site.com/ -v)).run
  #     expect(AudioBookCreator.logger.level).to eq(Logger::INFO)
  #   end
  # end

  # private

  # # NOTE: this uses any_instance because we don't want to instantiate anything
  # # could assign web and use a double instead
  # def expect_visit_page(url, *args)
  #   url = site(url)
  #   expect_any_instance_of(AudioBookCreator::Web).to receive(:[])
  #     .with(url).and_return(page(url, *args))
  # end
end
