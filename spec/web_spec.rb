require 'spec_helper'

describe AudioBookCreator::Web do
  let(:url) { site("page") }
  let(:page_contents) { "page contents"}

  it "visits uris" do
    expect_to_visit(url)
    expect(subject[uri("page")]).to eq(page_contents)
  end

  it "visits strings (and doesnt log)" do
    expect_to_visit(url)
    expect(subject[url]).to eq(page_contents)
    expect_to_have_logged()
  end

  context "with_logging" do
    before { enable_logging }
    it "logs visits" do
      expect_to_visit(url)
      expect(subject[url]).to eq(page_contents)
      expect_to_have_logged("fetch  #{url}")
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
