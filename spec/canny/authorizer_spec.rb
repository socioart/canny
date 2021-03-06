require "spec_helper"

module Canny
  RSpec.describe Authorizer do
    let(:authorizer) { Authorizer.new }
    let(:resource_class) {
      Class.new do
        def authorize_to_show(a, b, c = 1, d:)
          raise NotImplementedError
        end
      end
    }
    let(:resource) { resource_class.new }

    describe "can" do
      it "calls Result.can and return when authorize_to_*" do
        block = proc {}
        result = double(:result)

        expect(resource).to receive(:authorize_to_show).with(1, 2, 3, d: 4).and_return("Unauthorized")
        expect(Result).to receive(:can).with("Unauthorized", &block).and_return(result)

        expect(authorizer.can(:show, resource, 1, 2, 3, d: 4, &block)).to eq result
      end

      context "default argument validation success" do
        let(:authorizer) {
          Authorizer.new(:foo, bar: :baz).with_validator {|v, bar:| (v == :foo && bar == :baz) || "invalid argument" }
        }

        it "calls Result.can and return when authorize_to_*" do
          block = proc {}
          result = double(:result)

          expect(resource).to receive(:authorize_to_show).with(:foo, 1, 2, 3, bar: :baz, d: 4).and_return("Unauthorized")
          expect(Result).to receive(:can).with("Unauthorized", &block).and_return(result)

          expect(authorizer.can(:show, resource, 1, 2, 3, d: 4, &block)).to eq result
        end
      end

      context "default argument validation fail" do
        let(:authorizer) {
          Authorizer.new(:foobar, bar: :baz).with_validator {|v, bar:| (v == :foo && bar == :baz) || "invalid argument" }
        }

        it "cannot call authorize_to_* and unauthorize" do
          block = proc {}
          result = double(:result)

          expect(resource).not_to receive(:authorize_to_show)
          expect(Result).to receive(:can).with("invalid argument", &block).and_return(result)

          expect(authorizer.can(:show, resource, 1, 2, 3, d: 4, &block)).to eq result
        end
      end
    end

    describe "cannot" do
      it "calls Result.cannot and return when authorize_to_*" do
        block = proc {}
        result = double(:result)

        expect(resource).to receive(:authorize_to_show).with(1, 2, 3, d: 4).and_return("Unauthorized")
        expect(Result).to receive(:cannot).with("Unauthorized", &block).and_return(result)

        expect(authorizer.cannot(:show, resource, 1, 2, 3, d: 4, &block)).to eq result
      end
    end

    describe "can?" do
      it "returns true when authorize_to_* returns true" do
        expect(resource).to receive(:authorize_to_show).with(1, 2, 3, d: 4).and_return(true)
        expect(authorizer.can?(:show, resource, 1, 2, 3, d: 4)).to eq true
      end

      it "returns false when authorize_to_* returns except true" do
        expect(resource).to receive(:authorize_to_show).with(1, 2, 3, d: 4).and_return("Unauthorized")
        expect(authorizer.can?(:show, resource, 1, 2, 3, d: 4)).to eq false
      end
    end

    describe "cannot?" do
      it "returns false when authorize_to_* returns true" do
        expect(resource).to receive(:authorize_to_show).with(1, 2, 3, d: 4).and_return(true)
        expect(authorizer.cannot?(:show, resource, 1, 2, 3, d: 4)).to eq false
      end

      it "returns true when authorize_to_* returns except true" do
        expect(resource).to receive(:authorize_to_show).with(1, 2, 3, d: 4).and_return("Unauthorized")
        expect(authorizer.cannot?(:show, resource, 1, 2, 3, d: 4)).to eq true
      end
    end

    describe "authorize!" do
      it "does not raise error when authorize_to_* returns true" do
        expect(resource).to receive(:authorize_to_show).with(1, 2, 3, d: 4).and_return(true)
        expect {
          authorizer.authorize!(:show, resource, 1, 2, 3, d: 4)
        }.not_to raise_error
      end

      it "raises Unauthorized when authorize_to_* returns except true" do
        expect(resource).to receive(:authorize_to_show).with(1, 2, 3, d: 4).and_return("Unauthorized")
        expect {
          authorizer.authorize!(:show, resource, 1, 2, 3, d: 4)
        }.to raise_error(Unauthorized)
      end
    end
  end
end
