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
    subject { described_class.new("h1.title", "div", "a.link", "a.chapter") }
    it { expect(subject.title_path).to eq("h1.title") }
    it { expect(subject.body_path).to eq("div") }
    it { expect(subject.link_path).to eq("a.link") }
    it { expect(subject.chapter_path).to eq("a.chapter") }
  end

  describe "#page_links" do
    context "with no page_links" do
      let(:page) { dom("<p></p>")}
      it { expect(subject.page_links(page){ |r| r["href"] }).to be_empty}
    end
    context "with multiple page_links" do
      let(:page) { dom("<a href='tgt1'>a</a><a href='tgt2'>a</a>")}
      it { expect(subject.page_links(page){ |r| r["href"] }).to eq(%w(tgt1 tgt2))}
    end
  end

  describe "#chapter_links" do
    before { subject.chapter_path = "a.chapter"}
    context "with no chapter_links" do
      let(:page) { dom("<p></p>")}
      it { expect(subject.chapter_links(page){ |r| r["href"] }).to be_empty }
    end
    context "with only page_links" do
      let(:page) { dom("<p><a href='x'>x</a></p>")}
      it { expect(subject.chapter_links(page){ |r| r["href"] }).to be_empty }
    end
    context "with multiple chapter_links" do
      let(:page) { dom("<a class='chapter' href='tgt1'>a</a><a class='chapter' href='tgt2'>a</a>") }
      it { expect(subject.chapter_links(page){ |r| r["href"] }).to eq(%w(tgt1 tgt2)) }
    end
    context "with nil chapter_path" do
      before { subject.chapter_path = nil }
      let(:page) { dom("<a class='chapter' href='tgt1'>a</a><a class='chapter' href='tgt2'>a</a>") }
      it { expect(subject.chapter_links(page) { |r| r["href"] }).to be_empty }
    end
  end
end

