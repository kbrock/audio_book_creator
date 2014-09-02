require "spec_helper"

describe AudioBookCreator::WorkList do
  subject { described_class.new(max: nil) }

  context "#initialize" do
    # do we need to support this case?
    it "supports no parameters" do
      described_class.new
    end

    it "supports parameters" do
      expect(described_class.new(max: 5).max).to eq(5)
    end
  end

  context "#max" do
    before { subject.max = 2 }

    context "when visiting fewer pages" do
      before { subject << "url1" << "url2" }

      it "visits" do
        expect(subject.shift).to eq("url1")
        expect(subject.shift).to eq("url2")
        expect(subject.shift).to be_nil
      end
    end

    context "when it visits more pages" do
      before { subject << "url1" << "url2" << "url3" }
      it "raises error" do
        expect(subject.shift).to eq("url1")
        expect(subject.shift).to eq("url2")
        expect { subject.shift }.to raise_error(/visited 2 pages/)
      end
    end
  end

  it "skips duplicate pages" do
    subject << "page1" << "page1" << "page1"

    expect(subject.shift).to eq("page1")
    expect(subject.shift).to be_nil
  end

  it "skips previously visited pages" do
    subject << "page1"

    expect(subject.shift).to eq("page1")
    subject << "page1"

    expect(subject.shift).to be_nil
  end

  it "handles loops" do
    subject << "page1"

    expect(subject.shift).to eq("page1")
    subject << "page2"

    expect(subject.shift).to eq("page2")
    subject << "page1"
    subject << "page3"

    expect(subject.shift).to eq("page3")
    subject << "page1"
    subject << "page2"

    expect(subject.shift).to be_nil
  end

  context "#visited_counter" do
    context "with no max" do
      context "with 2 visits" do
        before { subject << "a" << "b" ; subject.shift ; subject.shift }
        it { expect(subject.visited_counter).to eq("3/all") }
      end
    end
    context "with max" do
      before { subject.max = 4 }
      context "with 2 visits" do
        before { subject << "a" << "b" ; subject.shift ; subject.shift }
        it { expect(subject.visited_counter).to eq("3/4") }
      end
    end
  end
end
