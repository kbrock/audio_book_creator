require "spec_helper"

describe AudioBookCreator::Spider do
  subject { described_class.new({}, link_path: "a") }
  context "#visit" do
    it "visit pages" do
      visit %w(page1 page2)
      expect_visit_page "page1"
      expect_visit_page "page2"
      subject.run
      expect(subject.cache[site('page1')]).to eq(page(site("page1")))
      expect(subject.cache[site('page2')]).to eq(page(site("page2")))
    end

    it "should visit a page only once" do
      visit %w(page1 page1 page1)
      expect_visit_page "page1"
      subject.run
      expect(subject.visited).to eq([uri("page1")])
    end

    it "visits relative pages" do
      subject.visit(site("page1"), "page2")
      expect_visit_page "page2"
      subject.run
    end
  end

  it "should spider pages" do
    visit "page1"
    expect_visit_page("page1", link("page2"))
    expect_visit_page("page2", link("page1"), link("page3"))
    expect_visit_page("page3", link("page2"))
    subject.run

    # correct order
    expect(subject.visited).to eq(uri(%w(page1 page2 page3)))
    # has contets from all pages
    expect(subject.cache.keys).to match_array(site(%w(page1 page2 page3)))
  end

  it "should only hit links in correct section" do
    subject.link_path = ".good a"
    visit "page1"
    expect_visit_page("page1", "<div class='good'>", link("good"), "</div>", link("bad"))
    expect_visit_page("good")
    subject.run

    expect(subject.visited).to eq(uri(%w(page1 good)))
  end

  it "ignores #target in url" do
    visit "page1"
    visit "page1#target"

    expect_visit_page("page1")
    subject.run

    expect(subject.visited).to eq(uri(%w(page1)))
  end

  it "spiders local pages only" do
    visit "page1"
    expect_visit_page("page1", link("good"), link("http://anothersite.com/bad"))
    expect { subject.run }.to raise_error
  end

  it "forgives remote pages if ignore_bogus set" do
    subject.ignore_bogus = true
    visit "page1"
    expect_visit_page("page1", link("good"), link("http://anothersite.com/bad"))
    expect_visit_page("good")
    subject.run

    expect(subject.visited).to eq(uri(%w(page1 good)))
  end

  it "doesnt visit bad pages" do
    expect { subject.visit("%@") }.to raise_error(/bad URI/)
  end

  context "#max" do
    it "should be ok visiting less than max pages" do
      subject.max = 4
      expect_visit_page("url1")
      expect_visit_page("url2")
      expect_visit_page("url3")
      expect_visit_page("url4")
      visit %w(url1 url2 url3 url4)
      subject.run
    end

    it "should notify user of visiting more than max pages" do
      subject.max = 4
      # visited is a private method
      subject.visited = uri(%w(url1 url2 url3))
      expect_visit_page("url4")
      visit %w(url1 url2 url3 url4 url5)
      expect { subject.run }.to raise_error(/visited 4 pages/)
    end
  end

  it "should load page from cache if already present" do
    visit "page1"

    # this is in the cache, so it will not be "opened"
    subject.cache[site("page2")] = page(site("page2"), link("page1"), link("page3"))

    expect_visit_page("page1", link("page2"))
    expect_visit_page("page3", link("page2"))
    subject.run

    expect(subject.visited).to eq(uri(%w(page1 page2 page3)))
    expect(subject.cache.keys).to match_array(site(%w(page1 page2 page3)))
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
      subject.send(:log) { "phrase" }
    end
  end

  context "visit with #extensions" do
    %w(/page / .html .php .jsp .htm).each do |ext|
      it "should visit #{ext}" do
        expect{ visit("page2#{ext}") }.not_to raise_error
      end
    end

    %w(.jpg .png .js).each do |ext|
      it "should not visit #{ext}" do
        expect{ visit("page2#{ext}") }.to raise_error
      end
    end
  end

  private

  def site(url)
    if url.is_a?(Array)
      url.map { |u| site(u) }
    else
      url.include?("http") ? url : "http://site.com/#{url}"
    end
  end

  def uri(url)
    if url.is_a?(Array)
      url.map { |u| uri(u) }
    else
      URI.parse(site(url))
    end
  end

  def visit(urls)
    Array(urls).flatten.each { |url| subject.visit(site(url)) }
  end

  def expect_visit_page(url, *args)
    url = site(url)
    expect_spider_to_visit_page(subject, url, *args)
  end
end
