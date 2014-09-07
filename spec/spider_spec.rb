require "spec_helper"

describe AudioBookCreator::Spider do
  let(:outstanding) { [] }
  let(:visited) { [] }
  let(:web) { {} }
  # NOTE: could use arrays here, but put caps just in case there are bugs (and make mutants fail)
  let(:invalid_urls) { {} }
  subject { described_class.new(web, outstanding, visited, invalid_urls, link_path: "a") }

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
    expect(subject.link_path).to eq("a")
  end

  context "#visit" do
    it "visit pages" do
      visit "page1"
      expect_visit_page "page1"
      subject.run

      expect(visited).to eq([uri("page1")])
      expect(outstanding).to eq([])
    end

    it "visit multiple pages" do
      visit %w(page1 page2)
      expect_visit_page "page1"
      expect_visit_page "page2"
      subject.run

      expect(visited).to eq(uri(%w(page1 page2)))
      expect(outstanding).to eq([])
    end

    it "visit unique list of pages" do
      visit %w(page1 page1 page1)
      expect_visit_page "page1"
      subject.run
    end

    # this double checks that visited is checked before deciding to visit another page
    it "dont visit a page that was already visited" do
      visited << uri("page1")
      expect_visit_no_pages

      visit "page1"
      expect(outstanding).to eq([])
      subject.run
    end

    it "skips loops" do
      visit "page1"
      expect_visit_page "page1", link("page1")
      subject.run
    end

    it "also accepts alias visit" do
      subject.visit site("page1")
      expect_visit_page "page1"
      subject.run
    end

    it "chains <<" do
      expect(subject << site("page1")).to eq(subject)
    end

    it "also accepts real urls" do
      subject << uri("page1")
      expect_visit_page "page1"
      subject.run
    end
  end

  it "follows relative links" do
    visit "page1"
    expect_visit_page("page1", link("page2"))
    expect_visit_page("page2")
    subject.run
  end

  it "follows absolute links" do
    visit "page1"
    expect_visit_page("page1", link(site("page2")))
    expect_visit_page("page2")
    subject.run
  end

  it "visits all pages once" do
    visit "page1"
    expect_visit_page("page1", link("page2"))
    expect_visit_page("page2", link("page1"), link("page3"))
    expect_visit_page("page3", link("page1"), link("page2"))
    subject.run
  end

  it "respects link_path" do
    subject.link_path = ".good a"
    visit "page1"
    expect_visit_page("page1", "<div class='good'>", link("good"), "</div>", link("bad"))
    expect_visit_page("good")
    subject.run
  end

  it "ignores #target in url" do
    visit "page1"
    visit "page1#target"

    expect_visit_page("page1")
    subject.run
  end

  it "skips bad pages" do
    expect { subject.visit("%@") }.to raise_error(/bad URI/)
  end

  context "with invalid_urls" do
    let(:invalid_urls) { double('hash', :include? => true) }

    it "skips invalid_urls" do
      subject.visit(site("page2"))
      expect_visit_no_pages
      subject.run
    end
  end

  context "logging" do
    it "logs page visits" do
      enable_logging
      visit "page1"
      expect_visit_page("page1")
      subject.run
      expect_to_have_logged("visit #{uri("page1")}")
    end

    it "doesnt log page visits" do
      visit "page1"
      expect_visit_page("page1")
      subject.run
      expect_to_have_logged()
    end
  end

  private

  def visit(urls)
    Array(urls).flatten.each { |url| subject << site(url) }
  end

  def expect_visit_no_pages
    is_expected.not_to receive(:open)
  end

  def expect_visit_page(url, *args)
    url = site(url)
    expect(web).to receive(:[]).with(url).and_return(page(url, *args))
  end
end
