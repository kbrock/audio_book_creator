require 'spec_helper'

describe AudioBookCreator::Editor do
  it "should generate a page" do
    chapters = subject.parse("book5", [page("page1", "<h1>the title</h1>",
                        "<div id='story'>","<p>first paragraph</p>", "<p>second paragraph</p>", "</div>"
                        )])

    expect(chapters).to eq([AudioBookCreator::Chapter.new("book5", 1, "the title", "first paragraph\n\nsecond paragraph")])

  end
end
