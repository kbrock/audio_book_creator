require "spec_helper"

describe AudioBookCreator::Spider do
  let(:page_def) { AudioBookCreator::PageDef.new(nil, "h1", "p") }
  let(:web) { {} }
  # NOTE: could use arrays here, but put caps to catch bugs
  let(:outstanding) { AudioBookCreator::ArrayWithCap.new(3) }
  let(:visited)     { AudioBookCreator::ArrayWithCap.new(3) }
  let(:invalid_urls) { {} }
  subject { described_class.new(web, outstanding, visited, invalid_urls, page_def) }

  it "handles empty initializer" do
    pristine = described_class.new
    expect(pristine.web).to be_a(Hash)
    expect(pristine.outstanding).to be_a(Array)
    expect(pristine.visited).to be_a(Array)
    expect(pristine.invalid_urls).to be_a(Hash)
  end

  it "sets arguments" do
    expect(subject.web).to eq(web)
    expect(subject.outstanding).to eq(outstanding)
    expect(subject.visited).to eq(visited)
    expect(subject.invalid_urls).to eq(invalid_urls)
    expect(subject.page_def).to eq(page_def)
  end

  context "#visit" do
    it "visit pages" do
      expect_visit_page "page1"
      visit "page1"
      subject.run

      expect(visited).to eq([uri("page1")])
      expect(outstanding).to eq([])
    end

    it "visit multiple pages" do
      expect_visit_page "page1"
      expect_visit_page "page2"
      visit %w(page1 page2)
      subject.run

      expect(visited).to eq(uri(%w(page1 page2)))
      expect(outstanding).to eq([])
    end

    it "visit unique list of pages" do
      expect_visit_page "page1", link("page2"), link("page2"), link("page2")
      expect_visit_page "page2"
      visit "page1"
      subject.run
    end

    # this double checks that visited is checked before deciding to visit another page
    it "dont visit a page that was already visited" do
      visited << uri("page2")
      expect_visit_page "page1", link("page2")
      visit "page1"
      subject.run
    end

    it "skips loops" do
      expect_visit_page "page1", link("page1")
      visit "page1"
      subject.run
    end

    it "also accepts alias visit" do
      expect_visit_page "page1"
      subject.visit uri("page1")
      subject.run
    end

    it "chains <<" do
      expect(subject << uri("page1")).to eq(subject)
    end
    
    it "also accepts string urls" do
      expect_visit_page "page1"
      subject << site("page1")
      subject.run
    end
  end

  context "when links already in outstanding" do
    let(:outstanding) { [uri("page1")]}
    it "visits outstanding links" do
      expect_visit_page("page1")
      subject.run
    end
  end

  it "follows relative links" do
    expect_visit_page("page1", link("page2"))
    expect_visit_page("page2")
    visit "page1"
    subject.run
  end

  it "follows absolute links" do
    expect_visit_page("page1", link(site("page2")))
    expect_visit_page("page2")
    visit "page1"
    subject.run
  end

  it "visits all pages once" do
    expect_visit_page("page1", link("page2"))
    expect_visit_page("page2", link("page1"), link("page3"))
    expect_visit_page("page3", link("page1"), link("page2"))
    visit "page1"
    subject.run
  end

  it "respects page_def" do
    page_def.link_path = ".good a"
    expect_visit_page("page1", "<div class='good'>", link("good"), "</div>", link("bad"))
    expect_visit_page("good")
    visit "page1"
    subject.run
  end

  it "ignores #target in url" do
    expect_visit_page("page1", link("page1#target"))
    visit "page1"
    subject.run
  end

  it "skips bad pages" do
    expect_visit_page("page1", link("%@"))
    visit "page1"
    expect { subject.run }.to raise_error(/bad URI/)
  end

  context "with invalid_urls" do
    it "skips invalid_urls" do
      expect(invalid_urls).to receive(:include?).with(uri("page1")).and_return(true)
      expect_visit_no_pages
      visit "page1"
      subject.run
    end
  end

  context "logging" do
    it "logs page visits" do
      enable_logging
      expect_visit_page("page1")
      visit "page1"
      subject.run
      expect_to_have_logged("visit #{uri("page1")}")
    end

    it "doesnt log page visits" do
      expect_visit_page("page1")
      visit "page1"
      subject.run
      expect_to_have_logged()
    end
  end

  private

  def visit(urls)
    Array(urls).flatten.each { |url| subject << uri(url) }
  end

  def expect_visit_no_pages
    expect(web).not_to receive(:[])
  end

  def expect_visit_page(url, *args)
    url = site(url)
    expect(visited).to receive(:<<).with(uri(url)).and_call_original
    expect(web).to receive(:[]).with(url.to_s).and_return(page(url, *args))
  end
end
