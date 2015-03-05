require "spec_helper"

describe AudioBookCreator::Logging do
  subject { Class.new.tap { |c| c.send(:include, described_class) }.new}
  it "should not log strings when verbose is off" do
    subject.logger.info "phrase"
    expect_to_have_logged()
  end

  it "should log strings" do
    enable_logging
    subject.logger.info "phrase"
    expect_to_have_logged("phrase")
  end

  it "should log blocks" do
    enable_logging
    subject.logger.info { "phrase" }
    expect_to_have_logged("phrase")
  end
end
