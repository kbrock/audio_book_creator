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
    pristine = described_class.new
    pristine.title_path = "h3"
    pristine.body_path = "#story p"
    expect(pristine.parse([page("page1", "<h3>the title</h3>",
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

  it "should ignore body formatting" do
    expect(subject.parse([page("page1", "<h1>the title</h1>",
                               "<p><a href='#this'>first</a></p>", "<p><b>second</b></p>")
                         ])).to eq([chapter1])
  end

  it "should parse multiple pages" do
    expect(subject.parse([page("page1", "<h1>p1</h1>", "<p>first</p>"),
                          page("page2", "<h1>p2</h1>", "<p>second</p>"),
                         ])).to eq([chapter("first", "p1", 1), chapter("second", "p2", 2)])
  end

  it "should default the title if none found" do
    expect(subject.parse([page("page1", "<p>first</p>"),
                          page("page2", "<p>second</p>"),
                         ])).to eq([chapter("first", "Chapter 1", 1), chapter("second", "Chapter 2", 2)])
  end
end
