require "spec_helper"

describe AudioBookCreator::Spider do
  let(:cache) { {} }
  # NOTE: real work list would prevent dups / loops
  let(:work_list) { [] }
  let(:invalid_urls) { {} }
  subject { described_class.new(cache, work_list, invalid_urls, link_path: "a") }
  context "#visit" do
    it "visit pages" do
      visit %w(page1 page2)
      expect_visit_page "page1"
      expect_visit_page "page2"
      subject.run
      expect(cache[site('page1')]).to eq(page(site("page1")))
      expect(cache[site('page2')]).to eq(page(site("page2")))
    end

    it "should visit a page only once" do
      visit %w(page1 page1 page1)
      expect_visit_page "page1"
      subject.run
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
    expect_visit_page("page2", link("page3"))
    expect_visit_page("page3")
    subject.run

    # has contets from all pages
    expect(cache.keys).to match_array(site(%w(page1 page2 page3)))
  end

  it "should only hit links in correct section" do
    subject.link_path = ".good a"
    visit "page1"
    expect_visit_page("page1", "<div class='good'>", link("good"), "</div>", link("bad"))
    expect_visit_page("good")
    subject.run

    expect(cache.keys).to eq(site(%w(page1 good)))
  end

  it "ignores #target in url" do
    visit "page1"
    visit "page1#target"

    expect_visit_page("page1")
    subject.run
  end

  it "doesnt visit bad pages" do
    expect { subject.visit("%@") }.to raise_error(/bad URI/)
  end

  it "should load page from cache if already present" do
    visit "page1"

    # this is in the cache, so it will not be "opened"
    cache[site("page2")] = page(site("page2"), link("page3"))

    expect_visit_page("page1", link("page2"))
    expect_visit_page("page3")
    subject.run

    expect(cache.keys).to match_array(site(%w(page1 page2 page3)))
  end


  private

  def visit(urls)
    Array(urls).flatten.each { |url| subject.visit site(url) }
  end

  def expect_visit_page(url, *args)
    url = site(url)
    expect(subject).to receive(:open).with(url).and_return(double(read: page(url, *args)))
  end
end
