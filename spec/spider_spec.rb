require "spec_helper"

describe AudioBookCreator::Spider do
  # set a max to prevent errors from causing infinite loops
  let(:page_def) { AudioBookCreator::PageDef.new("h1", "p", "a", nil) }
  let(:web) { {} }
  let(:invalid_urls) { {} }
  # NOTE: could use arrays here, but put caps to catch bugs
  subject { described_class.new(page_def, web, invalid_urls) }

  it "handles empty initializer" do
    pristine = described_class.new(page_def)
    expect(pristine.web).to be_a(Hash)
    expect(pristine.invalid_urls).to be_a(Hash)
  end

  it "sets arguments" do
    expect(subject.page_def).to eq(page_def)
    expect(subject.web).to eq(web)
    expect(subject.invalid_urls).not_to be_nil
  end

  context "#visit" do
    it "visit pages" do
      expect_visit_page "page1", "x"
      expect(subject.run(uri(%w(page1)))).to eq([page(site("page1"),"x")])
    end

    it "visit multiple pages" do
      expect_visit_page "page1"
      expect_visit_page "page2"
      expect(subject.run(uri(%w(page1 page2))))
        .to eq([page(site("page1")), page(site("page2"))])
    end

    it "visit unique list of pages" do
      expect_visit_page "page1", link("page2"), link("page2")
      expect_visit_page "page2"
      expect(subject.run uri(%w(page1)))
        .to eq([page(site("page1"),link("page2"), link("page2")), page(site("page2"))])
    end

    it "skips loops" do
      expect_visit_page "page1", link("page1")
      subject.run uri(%w(page1))
    end

    it "also accepts string urls" do
      expect_visit_page "page1"
      subject.run site(%w(page1))
    end
  end

  it "follows relative links" do
    expect_visit_page("page1", link("page2"))
    expect_visit_page("page2")
    subject.run uri(%w(page1))
  end

  it "follows absolute links" do
    expect_visit_page("page1", link(site("page2")))
    expect_visit_page("page2")
    subject.run uri(%w(page1))
  end

  # in the end of the day, these links reference the local page which is ignored, so no code necessary
  it "skips empty, blank, and local ref links" do
    p1_contents = "<a id='a1'>a1</a>", "<a href=''>a2</a>", "<a href='#a'>x</a>", link("page2")
    expect_visit_page("page1", *p1_contents)
    expect_visit_page("page2")
    expect(subject.run uri(%w(page1))).to eq([page(site("page1"), *p1_contents), page(site("page2"))])
  end

  it "visits all pages once" do
    expect_visit_page("page1", link("page2"))
    expect_visit_page("page2", link("page1"), link("page3"))
    expect_visit_page("page3", link("page1"), link("page2"))
    subject.run uri(%w(page1))
  end

  it "leverages page_def to determine good links" do
    page_def.link_path = ".good a"
    expect_visit_page("page1", "<div class='good'>", link("good"), "</div>", link("bad"))
    expect_visit_page("good")
    subject.run uri(%w(page1))
  end

  it "ignores #target in url" do
    expect_visit_page("page1", link("page1#target"))
    subject.run uri(%w(page1))
  end

  it "skips bad urls" do
    expect_visit_once("page1", link("%@")) # it never gets to call a second time
    expect { subject.run uri(%w(page1)) }.to raise_error(/bad URI/)
  end

  context "with invalid_urls" do
    it "skips invalid_urls" do
      expect(subject.invalid_urls).to receive(:include?).with(uri("bad")).and_return(true)
      expect_visit_page("page1", link("bad"))
      subject.run uri(%w(page1))
    end
  end

  context "logging" do
    it "logs page visits" do
      enable_logging
      expect_visit_page("page1")
      subject.run uri(%w(page1))
      expect_to_have_logged("visit #{uri("page1")}")
    end

    it "doesnt log page visits" do
      expect_visit_page("page1")
      subject.run uri(%w(page1))
      expect_to_have_logged()
    end
  end

  private

  def expect_visit_no_pages
    expect(web).not_to receive(:[])
  end

  def expect_visit_page(url, *args)
    url = site(url)
    expect(web).to receive(:[]).with(url.to_s).twice.and_return(page(url, *args))
  end

  def expect_visit_once(url, *args)
    url = site(url)
    expect(web).to receive(:[]).with(url.to_s).and_return(page(url, *args))
  end
end
