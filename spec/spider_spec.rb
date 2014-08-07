require "spec_helper"

describe AudioBookCreator::Spider do
  it "should remember pages to visit" do
    subject.visit(%w(page1 page2))
    expect(subject).to receive(:open).with("page1").and_return(page("page1"))
    expect(subject).to receive(:open).with("page2").and_return(page("page2"))
    subject.run
    expect(subject.cache['page1']).to eq(page("page1"))
    expect(subject.cache['page2']).to eq(page("page2"))
  end

  it "should visit pages only once" do
    subject.visit(%w(page1 page1 page1))
    expect(subject).to receive(:open).with("page1").and_return("<html>page1</html>")
    subject.run
    expect(subject.visited).to eq(%w(page1))
  end

  it "should spider pages" do
    subject.visit(%w(page1))
    expect(subject).to receive(:open).with("page1").and_return(page("page1", link("page2")))
    expect(subject).to receive(:open).with("page2").and_return(page("page2", link("page1"), link("page3")))
    expect(subject).to receive(:open).with("page3").and_return(page("page3", link("page2")))
    subject.run

    # correct order
    expect(subject.visited).to eq(%w(page1 page2 page3))
    # has contets from all pages
    expect(subject.cache.keys).to match_array(%w(page1 page2 page3))
  end

  it "should only hit links in correct section" do
    subject.visit(%w(page1))
    expect(subject).to receive(:open).with("page1").and_return(page("page1",
                                                                    "<div class='good'>", link("good"), "</div>",
                                                                    link("bad")))
    expect(subject).to receive(:open).with("good").and_return(page("good"))
    subject.run(".good a")

    # correct order
    expect(subject.visited).to eq(%w(page1 good))
  end

  # private methods

  it "should not log strings when verbose is off" do
    subject.verbose = false
    expect(subject).not_to receive(:puts)
    subject.send(:log, "phrase")
  end

  it "should log strings" do
    subject.verbose = true
    expect(subject).to receive(:puts).with("phrase")
    subject.send(:log, "phrase")
  end

  it "should log blocks" do
    subject.verbose = true
    expect(subject).to receive(:puts).with("phrase")
    subject.send(:log) {"phrase"}
  end

  it "should be ok visiting less than max pages" do
    subject.max = 4
    subject.visit(%w(url1 url2 url3))
  end

  it "should notify user of visiting more than max pages" do
    subject.max = 4
    subject.visited = %w(url1 url2 url3)
    expect { subject.visit(%w(url4 url5)) }.to raise_error("too many pages")
  end

  it "should load page from cache if already present" do
    subject.load_from_cache = true
    subject.visit(%w(page1))

    # this is in the cache, so it will not be "opened"
    subject.cache["page2"] = page("page2", link("page1"), link("page3"))

    expect(subject).to receive(:open).with("page1").and_return(page("page1", link("page2")))
    expect(subject).to receive(:open).with("page3").and_return(page("page3", link("page2")))
    subject.run

    # correct order
    expect(subject.visited).to eq(%w(page1 page2 page3))
    # has contets from all pages
    expect(subject.cache.keys).to match_array(%w(page1 page2 page3))
  end

  private

  def link(url)
    %{<a href="#{url}">link</a>"}
  end

  def page(title, *args)
    %{<html><head><title>#{title}</title></head>
      <body>#{Array(args).join(" ")}</body>
      </html>}
  end
end
