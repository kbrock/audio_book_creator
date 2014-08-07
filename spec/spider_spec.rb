require "spec_helper"

describe AudioBookCreator::Spider do
  context "#visit" do
    it "visit pages" do
      subject.visit(%w(page1 page2))
      expect_visit_page "page1"
      expect_visit_page "page2"
      subject.run
      expect(subject.cache['page1']).to eq(page("page1"))
      expect(subject.cache['page2']).to eq(page("page2"))
    end

    it "should visit a page only once" do
      subject.visit(%w(page1 page1 page1))
      expect_visit_page "page1"
      subject.run
      expect(subject.visited).to eq(%w(page1))
    end
  end

  it "should spider pages" do
    subject.visit(%w(page1))
    expect_visit_page("page1", link("page2"))
    expect_visit_page("page2", link("page1"), link("page3"))
    expect_visit_page("page3", link("page2"))
    subject.run

    # correct order
    expect(subject.visited).to eq(%w(page1 page2 page3))
    # has contets from all pages
    expect(subject.cache.keys).to match_array(%w(page1 page2 page3))
  end

  it "should only hit links in correct section" do
    subject.visit(%w(page1))
    expect_visit_page("page1", "<div class='good'>", link("good"), "</div>", link("bad"))
    expect_visit_page("good")
    subject.run(".good a")

    # correct order
    expect(subject.visited).to eq(%w(page1 good))
  end

  # private methods

  context "#log" do
    it "should not log strings when verbose is off" do
      subject.verbose = false
      expect(subject).not_to receive(:puts)
      subject.send(:log, "phrase")
    end

    it "should log strings" do
      subject.verbose = true
      expect(subject).to receive(:puts).with("phrase")
      subject.send(:log, "phrase")
    end

    it "should log blocks" do
      subject.verbose = true
      expect(subject).to receive(:puts).with("phrase")
      subject.send(:log) {"phrase"}
    end
  end

  context "#max" do
    it "should be ok visiting less than max pages" do
      subject.max = 4
      expect_visit_page("url1")
      expect_visit_page("url2")
      expect_visit_page("url3")
      expect_visit_page("url4")
      subject.visit(%w(url1 url2 url3 url4))
      subject.run
    end

    it "should notify user of visiting more than max pages" do
      subject.max = 4
      subject.visited = %w(url1 url2 url3)
      expect_visit_page("url4")
      subject.visit(%w(url1 url2 url3 url4 url5))
      expect { subject.run }.to raise_error("visited 4 pages. use --max to override")
    end
  end

  it "should load page from cache if already present" do
    subject.load_from_cache = true
    subject.visit(%w(page1))

    # this is in the cache, so it will not be "opened"
    subject.cache["page2"] = page("page2", link("page1"), link("page3"))

    expect_visit_page("page1", link("page2"))
    expect_visit_page("page3", link("page2"))
    subject.run

    # correct order
    expect(subject.visited).to eq(%w(page1 page2 page3))
    # has contets from all pages
    expect(subject.cache.keys).to match_array(%w(page1 page2 page3))
  end

  private

  def expect_visit_page(url, *args)
    expect(subject).to receive(:open).with(url).once.and_return(page(url, *args))
  end

  def link(url)
    %{<a href="#{url}">link</a>"}
  end

  def page(title, *args)
    %{<html><head><title>#{title}</title></head>
      <body>#{Array(args).join(" ")}</body>
      </html>}
  end
end
