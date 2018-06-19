require 'spec_helper'

describe AudioBookCreator::Editor do
  let(:page_def) { AudioBookCreator::PageDef.new("h1", "p") }
  subject { described_class.new(page_def) }
  let(:chapter1) { chapter("first\n\nsecond", "the title") }
  it "should generate a page" do
    expect(subject.parse([web_page(uri("page1"), "page1", "<h1>the title</h1>",
                               "<p>first</p>", "<p>second</p>")
                         ])).to eq([chapter1])
  end

  it "should respect content path" do
    page_def.title_path = "h3"
    page_def.body_path = "#story p"
    expect(subject.parse([web_page(uri("page1"), "page1", "<h3>the title</h3>",
                                "<div id='story'>", "<p>first</p>", "<p>second</p>", "</div>",
                                "<p>bad</p>")
                          ])).to eq([chapter1])
  end

  it "should ignore body formatting" do
    expect(subject.parse([web_page(uri("page1"), "page1", "<h1>the title</h1>",
                               "<p><a href='#this'>first</a></p>", "<p><b>second</b></p>")
                         ])).to eq([chapter1])
  end

  it "should parse multiple pages" do
    expect(subject.parse([web_page(uri("page1"), "page1", "<h1>p1</h1>", "<p>first</p>"),
                          web_page(uri("page2"), "page2", "<h1>p2</h1>", "<p>second</p>"),
                         ])).to eq([chapter("first", "p1", 1), chapter("second", "p2", 2)])
  end

  # arbitrary - there won't be 2 titles but makes mutant happy
  it "should get (first) title" do
    expect(subject.parse([web_page(uri("page1"), "page1", "<h1>the title 1</h1>","<h1>the title 2</h1>",
                               "<p><a href='#this'>first</a></p>")
                         ])).to eq([chapter("first", "the title 1", 1)])
  end

  it "should default the title if none found" do
    expect(subject.parse([web_page(uri("page1"), "page1", "<p>first</p>"),
                          web_page(uri("page2"), "page2", "<p>second</p>"),
                         ])).to eq([chapter("first", "Chapter 1", 1), chapter("second", "Chapter 2", 2)])
  end
end
