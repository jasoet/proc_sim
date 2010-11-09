module Jasoet
  class Stack
    def initialize
      @the_stack = []
    end

    def push(item)
      @the_stack.push item
      self
    end

    def pop
      @the_stack.pop
      self
    end

    def count
      @the_stack.length
    end
  end
end