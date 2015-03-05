require 'spec_helper'

describe AudioBookCreator::Conductor do
  # context "#page_cache" do
  #   it "should have database based upon title" do
  #     subject.parse(%w(http://site.com/title))
  #     # defaults
  #     expect(subject.page_cache.filename).to eq(subject.surfer_def.cache_filename)
  #   end
  # end

  # context "#spider" do
  #   it "sets references" do
  #     subject.parse(%w(http://site.com/title))
  #     expect(subject.spider.page_def).to eq(subject.page_def)
  #     expect(subject.spider.web).to eq(subject.cached_web)
  #     expect(subject.spider.invalid_urls).to eq(subject.invalid_urls)
  #   end
  # end

  # context "#invalid_urls" do
  #   it "sets host for invalid urls" do
  #     subject.parse(%w(http://site.com/title))
  #     expect(subject.invalid_urls.host).to eq("site.com")
  #   end
  # end


  # context "#cached_web" do
  #   it "default" do
  #     subject.parse(%w(http://site.com/title))
  #     expect(subject.cached_web.cache).to eq(subject.page_cache)
  #     expect(subject.cached_web.main).to eq(subject.web)
  #     expect(subject.cached_web).to respond_to(:main)
  #   end
  # end

  # context "#editor" do
  #   it "should create editor" do
  #     subject.parse(%w(http://site.com/title))
  #     # defaults
  #     expect(subject.editor.page_def).to eq(subject.page_def)
  #     # needs to be an editor
  #     expect(subject.editor).to respond_to(:parse)
  #     # hack
  #     expect(subject.editor).not_to eq(subject)
  #   end
  # end

  # context "#speaker" do
  #   it "should create speaker" do
  #     subject.parse(%w(http://site.com/title))
  #     # defaults
  #     expect(subject.speaker.speaker_def).to eq(subject.speaker_def)
  #     expect(subject.speaker.book_def).to eq(subject.book_def)
  #     expect(subject.speaker_def.regen_audio).not_to be_truthy
  #     expect(subject.speaker).to respond_to(:say)
  #   end

  #   it "should set force" do
  #     subject.parse(%w(http://site.com/title --force-audio))
  #     expect(subject.speaker_def.regen_audio).to be_truthy
  #   end
  # end

  # context "#binder" do
  #   it "should create a binder" do
  #     subject.parse(%w(http://site.com/title))
  #     # defaults
  #     expect(subject.binder.book_def).to eq(subject.book_def)
  #     expect(subject.binder.speaker_def).to eq(subject.speaker_def)
  #     # NOTE: not currently passed
  #   end
  # end

  # describe "#creator" do
  #   it "should create a book creator" do
  #     subject.parse(%w(http://site.com/title))
  #     expect(subject.creator.spider).to  eq(subject.spider)
  #     expect(subject.creator.editor).to  eq(subject.editor)
  #     expect(subject.creator.speaker).to eq(subject.speaker)
  #     expect(subject.creator.binder).to  eq(subject.binder)
  #     expect(subject.creator).to respond_to(:create)
  #   end
  # end

#      expect(subject.page_cache.filename).to eq(subject.surfer_def.cache_filename)

end
