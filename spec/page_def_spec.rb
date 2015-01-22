require "spec_helper"

describe AudioBookCreator::PageDef do
  context "with no parameter" do
    subject { described_class.new() }
    it { expect(subject.title_path).to eq("h1") }
    it { expect(subject.body_path).to eq("p") }
    it { expect(subject.link_path).to eq("a") }
    it { expect(subject.max_paragraphs).to be_nil }
  end

  context "with all parameters" do
    subject { described_class.new("h1.title", "div", "a.link", 55) }
    it { expect(subject.title_path).to eq("h1.title") }
    it { expect(subject.body_path).to eq("div") }
    it { expect(subject.link_path).to eq("a.link") }
    it { expect(subject.max_paragraphs).to eq(55) }
  end

  describe "#title" do
    context "with no title" do
      let(:page) { dom("<p></p>")}
      it { expect(subject.title(page)).to be_nil}
    end
    context "with title" do
      let(:page) { dom("<h1>title</h1>")}
      it { expect(subject.title(page)).to eq("title")}
    end
  end

  # NOTE: chapter uses array.join
  describe "#body" do
    context "with no body" do
      let(:page) { dom("<h1></h1>")}
      it { expect(subject.body(page)).to be_empty}
    end
    context "with body" do
      let(:page) { dom("<p>p1</p>")}
      it { expect(Array(subject.body(page)).join).to eq("p1") }
    end
    context "with many bodies" do
      let(:page) { dom("<p>p1</p><p>p2</p><p>p3</p><p>p4</p>")}
      it { expect(Array(subject.body(page)).join).to eq(%w(p1 p2 p3 p4).join) }
    end
    context "with low limit" do
      let(:page) { dom("<p>p1</p><p>p2</p><p>p3</p><p>p4</p>")}
      before { subject.max_paragraphs = 3}
      it { expect(Array(subject.body(page)).join).to eq(%w(p1 p2 p3).join) }
    end
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
end

