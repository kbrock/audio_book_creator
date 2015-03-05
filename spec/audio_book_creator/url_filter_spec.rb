require 'spec_helper'

describe AudioBookCreator::UrlFilter do
  subject { described_class.new(uri("page1")) }

  context "#host" do
    subject { described_class.new(nil) }

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
    expect(subject.include?(uri("good"))).not_to be_truthy
    expect(subject.include?(uri("http://anothersite.com/bad"))).not_to be_truthy
    expect(subject.include?(uri("http://anothersite.com/bad"))).not_to be_truthy
  end

  it "spiders local pages only" do
    expect(subject.include?(uri("page1"))).not_to be_truthy
    expect(subject.include?(uri("good"))).not_to be_truthy
    url = uri("http://anothersite.com/bad")
    expect(subject.logger).to receive(:warn) { |&arg| expect(arg.call).to eq("ignoring remote url #{url}") }
    expect { subject.include?(url) }.to raise_error("remote url #{url}")
  end

  context "visit with #extensions" do
    %w(/page / .html .php .jsp .htm).each do |ext|
      it "visits #{ext}" do
        expect(subject.include?(uri("page2#{ext}"))).not_to be_truthy
      end
    end

    %w(.jpg .png .js).each do |ext|
      it "doesnt visit #{ext}" do
        url = uri("page2#{ext}")
        expect(subject.logger).to receive(:warn) { |&arg| expect(arg.call).to eq("ignoring bad file extension #{url}") }
        expect { subject.include?(url) }.to raise_error("bad file extension")
      end
    end
  end
end
