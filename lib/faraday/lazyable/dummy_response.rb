module Faraday
  class Lazyable
    class DummyResponse < BasicObject
      instance_methods.each do |method_name|
        undef_method(method_name) unless method_name == :__send__
      end

      def initialize(&block)
        @block = block
      end

      private

      def method_missing(method_name, *args, &block)
        __response__.__send__(method_name, *args, &block)
      end

      def __response__
        @response ||= @block.call
      end
    end
  end
end
