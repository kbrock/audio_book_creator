require 'spec_helper'

describe AudioBookCreator::Web do
  let(:url) { site("page") }
  let(:page_contents) { "page contents"}

  context "#initialize with no params" do
    it { expect(subject.max).to be_nil }
    it { expect(subject.count).to eq(0) }
  end

  context "#initialize with max" do
    subject { described_class.new(5) }
    it { expect(subject.max).to eq(5) }
  end

  it "visits uris" do
    expect_to_visit(url)
    expect(subject[uri("page")]).to eq(page_contents)
  end

  it "visits strings (and doesnt log)" do
    expect_to_visit(url)
    expect(subject[url]).to eq(page_contents)
    expect_to_have_logged()
  end

  context "with max" do
    before { subject.max = 2 }

    it "visits" do
      expect_to_visit(url)
      expect_to_visit(url)
      expect(subject[url]).to eq(page_contents)
      expect(subject[url]).to eq(page_contents)
      expect { subject[url] }.to raise_error(/visited 2 pages/)
    end
  end

  context "with_logging" do
    before { enable_logging }
    it "logs visits" do
      expect_to_visit(url)
      expect(subject[url]).to eq(page_contents)
      expect_to_have_logged("fetch  #{url} [1]")
    end

    context "with max" do
      before { subject.max = 2 }
      it "logs visit showing max" do
        expect_to_visit(url)
        expect(subject[url]).to eq(page_contents)
        expect_to_have_logged("fetch  #{url} [1/2]")
      end
    end
  end

  private

  # def expect_not_to_visit
  #   expect(subject).not_to receive(:open)
  # end
  def expect_to_visit(site)
    expect(subject).to receive(:open).with(site.to_s).and_return(double("io", :read => page_contents))
  end
end
