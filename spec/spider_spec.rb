require "spec_helper"

describe AudioBookCreator::Spider do
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
      expect(subject.visited).to eq([site("page1")])
    end
  end

  it "should spider pages" do
    visit "page1"
    expect_visit_page("page1", link("page2"))
    expect_visit_page("page2", link("page1"), link("page3"))
    expect_visit_page("page3", link("page2"))
    subject.run

    # correct order
    expect(subject.visited).to eq(site(%w(page1 page2 page3)))
    # has contets from all pages
    expect(subject.cache.keys).to match_array(site(%w(page1 page2 page3)))
  end

  it "should only hit links in correct section" do
    visit "page1"
    expect_visit_page("page1", "<div class='good'>", link("good"), "</div>", link("bad"))
    expect_visit_page("good")
    subject.run(".good a")

    expect(subject.visited).to eq(site(%w(page1 good)))
  end

  it "should freak if visiting a non local page" do
    visit "page1"
    expect_visit_page("page1", link("good"), link("http://anothersite.com/bad"))
    expect { subject.run("a") }.to raise_error
  end

  it "should only link to local pages" do
    subject.ignore_bogus = true
    visit "page1"
    expect_visit_page("page1", link("good"), link("http://anothersite.com/bad"))
    expect_visit_page("good")
    subject.run("a")

    expect(subject.visited).to eq(site(%w(page1 good)))
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
      subject.visited = site(%w(url1 url2 url3))
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

    expect(subject.visited).to eq(site(%w(page1 page2 page3)))
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

  context "#local_href" do
    let (:first_page) { "http://www.thesite.com/book/page1.html" }
    before do
      # establish base site (we can't venture to other sites)
      subject.visit(first_page)
    end

    it "should know local pages" do
      expect(subject.local_href(first_page, "page2.html")).to eq("http://www.thesite.com/book/page2.html")
    end

    %w(/page / .html .php .jsp .htm).each do |ext|
      it "should not visit #{ext}" do
        expect(subject.local_href(first_page, "page2#{ext}")).not_to be_nil
      end
    end

    %w(.jpg .png .js).each do |ext|
      it "should not visit #{ext}" do
        expect(subject.local_href(first_page, "page2#{ext}")).to be_nil
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

  def visit(urls)
    Array(urls).flatten.each { |url| subject.visit(site(url)) }
  end

  def expect_visit_page(url, *args)
    url = site(url)
    expect(subject).to receive(:open).with(url).once.and_return(double(read: page(url, *args)))
  end
end
