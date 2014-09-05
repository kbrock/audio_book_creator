require 'spec_helper'

describe AudioBookCreator::UrlFilter do
  subject { described_class.new(host: uri("page1")) }

  context "#host" do
    subject { described_class.new }

    it "supports strings (and nils)" do
      subject.host = "http://site.com/page"
      expect(subject.host).to eq("site.com")

      subject.host = nil
      expect(subject.host).to be_nil
    end

    it "supports uris" do
      subject.host = uri("page")
      expect(subject.host).to eq(uri("page").host)      
    end
  end

  it "spiders without a host" do
    subject.host = nil
    expect(subject[uri("good")]).not_to be_truthy
    expect(subject[uri("http://anothersite.com/bad")]).not_to be_truthy
    expect(subject.include?(uri("http://anothersite.com/bad"))).not_to be_truthy
  end

  it "spiders local pages only" do
    expect(subject[uri("page1")]).not_to be_truthy
    expect(subject[uri("good")]).not_to be_truthy
    url = uri("http://anothersite.com/bad")
    expect { subject[url] }.to raise_error("remote url #{url}")
  end

  context "#with ignore_bogus" do
    before { subject.ignore_bogus = true}

    it "forgives remote pages" do
      expect_to_log("")
      expect(subject[uri("http://anothersite.com/bad")]).to be_truthy
    end

    it "forgives bad extensions" do
      expect_to_log("")
      expect(subject[uri("page.abc")]).to be_truthy
    end

    context "#with verbose" do
      before { verbose_logging }

      it "logs remote pages" do
        url = uri("http://anothersite.com/bad")
        expect_to_log("ignoring remote url #{url}")
        expect(subject[url]).to be_truthy
      end      

      it "logs bad extensions" do
        url = uri("page.abc")
        expect_to_log("ignoring bad file extension #{url}")
        expect(subject[url]).to be_truthy
      end      
    end
  end

  context "visit with #extensions" do
    %w(/page / .html .php .jsp .htm).each do |ext|
      it "visits #{ext}" do
        expect(subject[uri("page2#{ext}")]).not_to be_truthy
      end
    end

    %w(.jpg .png .js).each do |ext|
      it "doesnt visit #{ext}" do
        expect { subject[uri("page2#{ext}")] }.to raise_error(/bad file extension/)
      end
    end
  end
end
