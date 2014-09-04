require "spec_helper"

describe AudioBookCreator::Logging do
  subject { Class.new.tap { |c| c.send(:include, described_class) }.new}
  it "should not log strings when verbose is off" do
    subject.verbose = false
    expect($stdout).not_to receive(:puts)
    subject.send(:log, "phrase")
  end

  it "should log strings" do
    subject.verbose = true
    expect($stdout).to receive(:puts).with("phrase")
    subject.send(:log, "phrase")
  end

  it "should log blocks" do
    subject.verbose = true
    expect($stdout).to receive(:puts).with("phrase")
    subject.send(:log) { "phrase" }
  end
end
