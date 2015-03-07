require 'spec_helper'

describe AudioBookCreator::UrlFilter do
  subject { described_class.new(uri("page1")) }

  context "#host" do
    subject { described_class.new(nil) }

    it { expect(subject.host).to be_nil }

    it "supports strings (and nils)" do
      subject = described_class.new("http://site.com/page")
      expect(subject.host).to eq("site.com")
    end

    it "supports uris" do
      subject = described_class.new(uri("page"))
      expect(subject.host).to eq(uri("page").host)
    end

    it "spiders without a host" do
      expect(subject.include?(uri("good"))).not_to be_truthy
      expect(subject.include?(uri("http://anothersite.com/bad"))).not_to be_truthy
    end
  end

  it "spiders local pages only" do
    expect(subject.include?(uri("page1"))).not_to be_truthy
    expect(subject.include?(uri("good"))).not_to be_truthy
    url = uri("http://anothersite.com/bad")
    # odd syntax because we are testing the return value of the block passed to logger.warn
    expect(subject.logger).to receive(:warn) { |&arg| expect(arg.call).to eq("ignoring remote url #{url}") }
    expect { subject.include?(url) }.to raise_error("remote url #{url}")
  end

  context "visit with #extensions" do
    %w(/page / .html .php .jsp .htm).each do |ext|
      it "visits page2#{ext}" do
        expect(subject.include?(uri("page2#{ext}"))).not_to be_truthy
      end
    end

    %w(.jpg .png .js).each do |ext|
      it "doesnt visit page2#{ext}" do
        url = uri("page2#{ext}")
        # odd syntax because we are testing the return value of the block passed to logger.warn
        expect(subject.logger).to receive(:warn) { |&arg| expect(arg.call).to eq("ignoring bad file extension #{url}") }
        expect { subject.include?(url) }.to raise_error("bad file extension")
      end
    end
  end
end
