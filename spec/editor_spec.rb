require 'spec_helper'

describe AudioBookCreator::Editor do
  it "should generate a page" do
    subject.content = "p"
    chapters = subject.parse("book5", [page("page1", "<h1>the title</h1>",
                        "<div id='story'>","<p>first</p>", "<p>second</p>", "</div>"
                        )])

    expect(chapters).to eq([chapter("first\n\nsecond")])

  end

  it "should respect content path" do
    subject.content = "#story p"
    chapters = subject.parse("book5", [page("page1", "<h1>the title</h1>",
                        "<div id='story'>","<p>first</p>", "<p>second</p>", "</div>", "<p>bad</p>"
                        )])

    expect(chapters).to eq([chapter("first\n\nsecond")])

  end

  it "should limit content" do
    subject.content = "p"
    subject.max_paragraphs = 2
    chapters = subject.parse("book5", [page("page1", "<h1>the title</h1>",
                        "<div id='story'>","<p>first</p>", "<p>second</p>", "<p>third</p>", "</div>"
                        )])

    expect(chapters).to eq([chapter("first\n\nsecond")])

  end

  def chapter(body)
    AudioBookCreator::Chapter.new(book: "book5", number: 1, title: "the title", body: body)
  end
end
