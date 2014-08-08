require 'spec_helper'

describe AudioBookCreator::Editor do
  it "should generate a page" do
    chapters = subject.parse([page("page1", "<h1>the title</h1>",
                        "<div id='story'>","<p>first paragraph</p>", "<p>second paragraph</p>", "</div>"
                        )])

    expect(chapters).to eq([AudioBookCreator::Chapter.new("the title", "first paragraph\n\nsecond paragraph\n\n")])

  end
end
