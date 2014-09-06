require "spec_helper"

describe AudioBookCreator::Runner do
  subject { described_class.new }

  context "with successful command" do
    it "runs commands with arguments" do
      expect(subject).to receive(:system).with("cmd", "arg1", "arg2").and_return(true)
      subject.run!("cmd", :params => %w(arg1 arg2))
    end

    it "runs commands with non string arguments" do
      expect(subject).to receive(:system).with("cmd", "arg1", "1").and_return(true)
      subject.run!("cmd", :params => ["arg1", 1])
    end

    it "runs commands with hashes and nested arrays" do
      expect(subject).to receive(:system).with("cmd", "arg1", "a", "b").and_return(true)
      subject.run!("cmd", :params => {arg1: %w(a b)})
    end

    it "runs commands with nils" do
      expect(subject).to receive(:system).with("cmd", "arg1").and_return(true)
      subject.run!("cmd", :params => {arg1: nil})
    end

    context "without verbose" do
      it "doesnt log" do
        expect(subject).to receive(:system).and_return(true)
        expect_to_log("")
        subject.run!("cmd", :params => %w(arg1 arg2))
      end
    end

    context "with verbose" do
      before { enable_logging }
      it "logs messages" do
        expect(subject).to receive(:system).and_return(true)
        expect_to_log(/run: cmd arg1 arg2/, "", "suggess", "")
        expect(subject.run!("cmd", :params => %w(arg1 arg2))).to be_truthy
      end      
    end
  end

  context "with failing command" do
    it "returns false" do
      expect(subject).to receive(:system).and_return(false)
      expect(subject.run("cmd", :params => %w(arg1 arg2))).not_to be_truthy
    end

    it "raises exception" do
      expect(subject).to receive(:system).and_return(false)
      expect { subject.run!("cmd", :params => %w(arg1 arg2)) }.to raise_error(/trouble/)
    end

    context "with verbose" do
      before { enable_logging }
      it "logs messages" do
        expect(subject).to receive(:system).and_return(false)
        expect_to_log(/run.*cmd.*arg1 arg2/, "", "issue", "")
        expect { subject.run!("cmd", :params => %w(arg1 arg2)) }.to raise_error(/trouble/)
      end
    end
  end
end
