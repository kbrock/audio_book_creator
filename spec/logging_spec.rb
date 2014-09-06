require "spec_helper"

describe AudioBookCreator::Logging do
  subject { Class.new.tap { |c| c.send(:include, described_class) }.new}
  it "should not log strings when verbose is off" do
    expect_to_log("")
    subject.logger.info "phrase"
  end

  it "should log strings" do
    enable_logging
    expect_to_log("phrase")
    subject.logger.info "phrase"
  end

  it "should log blocks" do
    enable_logging
    expect_to_log("phrase")
    subject.logger.info { "phrase" }
  end
end
