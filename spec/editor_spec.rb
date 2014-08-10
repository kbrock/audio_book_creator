require 'spec_helper'

describe AudioBookCreator::Editor do
  subject { described_class.new(title_path: "h1", body_path: "p") }
  let(:chapter1) { chapter("first\n\nsecond", "the title") }
  it "should generate a page" do
    expect(subject.parse([page("page1", "<h1>the title</h1>",
                               "<p>first</p>", "<p>second</p>")
                         ])).to eq([chapter1])
  end

  it "should respect content path" do
    subject.body_path = "#story p"
    expect(subject.parse([page("page1", "<h1>the title</h1>",
                               "<div id='story'>", "<p>first</p>", "<p>second</p>", "</div>",
                               "<p>bad</p>")
                         ])).to eq([chapter1])
  end

  it "should limit content" do
    subject.max_paragraphs = 2
    expect(subject.parse([page("page1", "<h1>the title</h1>",
                               "<p>first</p>", "<p>second</p>", "<p>third</p>")
                         ])).to eq([chapter1])
  end
end
