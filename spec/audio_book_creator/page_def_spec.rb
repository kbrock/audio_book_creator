require "spec_helper"

describe AudioBookCreator::PageDef do
  context "with no parameter" do
    subject { described_class.new() }
    it { expect(subject.title_path).to eq("h1") }
    it { expect(subject.body_path).to eq("p") }
    it { expect(subject.link_path).to eq("a") }
    it { expect(subject.chapter_path).to be_nil }
  end

  context "with all parameters" do
    subject { described_class.new("h1.title", "div", "a.link", "a.chapter", {:url => true}) }
    it { expect(subject.title_path).to eq("h1.title") }
    it { expect(subject.body_path).to eq("div") }
    it { expect(subject.link_path).to eq("a.link") }
    it { expect(subject.chapter_path).to eq("a.chapter") }
    it { expect(subject.invalid_urls).to eq({:url => true}) }
  end

  describe "#page_links" do
    let(:root) { uri("") }
    context "with no page_links" do
      let(:wp) { web_page(root, "title","<p></p>")}
      it { expect(subject.page_links(wp)).to be_empty}
    end
    context "with multiple page_links" do
      let(:wp) { web_page(root, "title", "<a href='tgt1'>a</a><a href='tgt2'>a</a>")}
      it { expect(subject.page_links(wp)).to eq(uri(%w(tgt1 tgt2))) }
    end
    context "with bad page_links" do
      before { subject.invalid_urls = {uri("bad") => false}}
      let(:wp) { web_page(root, "title", "<a href='tgt1'>a</a><a href='bad'>a</a>")}
      it { expect(subject.page_links(wp)).to eq(uri(%w(tgt1))) }
    end
  end

  describe "#chapter_links" do
    let(:root) { uri("") }
    before { subject.chapter_path = "a.chapter"}
    context "with no chapter_links" do
      let(:wp) { web_page(root, "title","<p></p>")}
      it { expect(subject.chapter_links(wp)).to be_empty }
    end
    context "with only page_links" do
      let(:wp) { web_page(root, "title", "<p><a href='x'>x</a></p>")}
      it { expect(subject.chapter_links(wp)).to be_empty }
    end
    context "with multiple chapter_links" do
      let(:wp) { web_page(root, "title", "<a class='chapter' href='tgt1'>a</a><a class='chapter' href='tgt2'>a</a>") }
      it { expect(subject.chapter_links(wp)).to eq(uri(%w(tgt1 tgt2))) }
    end
    context "with nil chapter_path" do
      before { subject.chapter_path = nil }
      let(:wp) { web_page(root, "title", "<a class='chapter' href='tgt1'>a</a><a class='chapter' href='tgt2'>a</a>") }
      it { expect(subject.chapter_links(wp)).to be_empty }
    end
    context "with bad chapter_links" do
      before { subject.invalid_urls = {uri("bad") => false}}
      let(:wp) { web_page(root, "title", "<a class='chapter' href='tgt1'>a</a><a class='chapter' href='bad'>a</a>")}
      it { expect(subject.chapter_links(wp)).to eq(uri(%w(tgt1))) }
    end
  end
end

