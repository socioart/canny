module Canna
  class Result
    class << self
      def can(true_or_reason, &block_for_can)
        new(:can, true_or_reason, &block_for_can)
      end

      def cannot(true_or_reason, &block_for_cannot)
        new(:cannot, true_or_reason, &block_for_cannot)
      end

      private :new
    end

    attr_reader :reason, :type, :value

    def initialize(type, true_or_reason, &block)
      @type = type
      @success = true_or_reason == true
      @reason = true_or_reason unless success?

      return unless block_given?

      case
      when type == :can && success?
        @value = block.call
      when type == :cannot && !success?
        @value = block.call(reason)
      end
    end

    def success?
      @success
    end

    def else(&block)
      case
      when type == :can && !success?
        @value = block.call(reason)
      when type == :cannot && success?
        @value = block.call
      end
      self
    end
  end
end
