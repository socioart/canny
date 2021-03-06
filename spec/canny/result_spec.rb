require "spec_helper"

module Canny
  RSpec.describe Result do
    describe ".can" do
      context "first argument is true" do
        it "runs block and store value" do
          foo = double(:foo)
          expect(foo).to receive(:success).and_return("success")

          r = Result.can(true) {
            foo.success
          }
          expect(r.value).to eq "success"
        end

        it "runs block and store value, and does not run else block" do
          foo = double(:foo)
          expect(foo).to receive(:success).and_return("success")
          expect(foo).not_to receive(:fail)

          r = Result.can(true) {
            foo.success
          }.else {|reason|
            foo.fail(reason)
          }
          expect(r.value).to eq "success"
        end

        it "does not run else block and value is nil" do
          foo = double(:foo)
          expect(foo).not_to receive(:fail)

          r = Result.can(true).else {|reason|
            foo.fail(reason)
          }
          expect(r.value).to eq nil
        end
      end

      context "first argument is not true" do
        it "does not run block and value is nil" do
          foo = double(:foo)
          expect(foo).not_to receive(:success)

          r = Result.can("Unauthorized") {
            foo.success
          }
          expect(r.value).to eq nil
        end

        it "does not run block, and run else block and store value" do
          foo = double(:foo)
          expect(foo).not_to receive(:success)
          expect(foo).to receive(:fail).with("Unauthorized").and_return("fail")

          r = Result.can("Unauthorized") {
            foo.success
          }.else {|reason|
            foo.fail(reason)
          }
          expect(r.value).to eq "fail"
        end

        it "runs else block and store value" do
          foo = double(:foo)
          expect(foo).to receive(:fail).with("Unauthorized").and_return("fail")

          r = Result.can("Unauthorized").else {|reason|
            foo.fail(reason)
          }
          expect(r.value).to eq "fail"
        end
      end
    end

    describe ".cannot" do
      context "first argument is true" do
        it "does not run block and value is nil" do
          foo = double(:foo)
          expect(foo).not_to receive(:fail)

          r = Result.cannot(true) {|reason|
            foo.fail(reason)
          }
          expect(r.value).to eq nil
        end

        it "does not run block, and runs else block and store value" do
          foo = double(:foo)
          expect(foo).not_to receive(:fail)
          expect(foo).to receive(:success).and_return("success")

          r = Result.cannot(true) {|reason|
            foo.fail(reason)
          }.else {
            foo.success
          }
          expect(r.value).to eq "success"
        end

        it "runs else block and store value" do
          foo = double(:foo)
          expect(foo).to receive(:success).and_return("success")

          r = Result.cannot(true).else {
            foo.success
          }
          expect(r.value).to eq "success"
        end
      end

      context "first argument is not true" do
        it "runs block and store value" do
          foo = double(:foo)
          expect(foo).to receive(:fail).with("Unauthorized").and_return("fail")

          r = Result.cannot("Unauthorized") {|reason|
            foo.fail(reason)
          }
          expect(r.value).to eq "fail"
        end

        it "runs block and does not run else block" do
          foo = double(:foo)
          expect(foo).to receive(:fail).with("Unauthorized").and_return("fail")
          expect(foo).not_to receive(:success)

          r = Result.cannot("Unauthorized") {|reason|
            foo.fail(reason)
          }.else {
            foo.success
          }
          expect(r.value).to eq "fail"
        end

        it "does not run else block and value is nil" do
          foo = double(:foo)
          expect(foo).not_to receive(:success)

          r = Result.cannot("Unauthorized").else {
            foo.success
          }
          expect(r.value).to eq nil
        end
      end
    end

    describe "authorized? and reason" do
      context "constructor's first argument is true" do
        let(:result) { Result.can(true) }
        it "returns true for succes?, nil fo reason" do
          expect(result.authorized?).to eq true
          expect(result.reason).to eq nil
        end
      end

      context "constructor's first argument is not true" do
        let(:result) { Result.can("Unauthorized") }
        it "returns false for succes?, first argument fo reason" do
          expect(result.authorized?).to eq false
          expect(result.reason).to eq "Unauthorized"
        end
      end
    end

    describe "run" do
      context "call twice" do
        context "run block" do
          it "raises error" do
            first = double(:first)
            expect(first).to receive(:call)
            second = double(:second)
            expect(second).not_to receive(:call)

            r = Result.can(true)
            r.run { first.call }

            expect {
              r.run { second.call }
            }.to raise_error(RuntimeError)
          end
        end

        context "not run block" do
          it "raises error" do
            first = double(:first)
            expect(first).not_to receive(:call)
            second = double(:second)
            expect(second).not_to receive(:call)

            r = Result.can(false)
            r.run { first.call }

            expect {
              r.run { second.call }
            }.to raise_error(RuntimeError)
          end
        end
      end
    end

    describe "else" do
      context "call twice" do
        context "run block" do
          it "raises error" do
            first = double(:first)
            expect(first).to receive(:call)
            second = double(:second)
            expect(second).not_to receive(:call)

            r = Result.can(false)
            r.else { first.call }

            expect {
              r.else { second.call }
            }.to raise_error(RuntimeError)
          end
        end

        context "not run block" do
          it "raises error" do
            first = double(:first)
            expect(first).not_to receive(:call)
            second = double(:second)
            expect(second).not_to receive(:call)

            r = Result.can(true)
            r.else { first.call }

            expect {
              r.else { second.call }
            }.to raise_error(RuntimeError)
          end
        end
      end
    end
  end
end
