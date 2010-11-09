module Jasoet
  class Queue

    def initialize
      @store = []
    end

    def enq(x)
      @store << x
    end

    def deq
      @store.shift
    end

    def peek
      @store.first
    end

    def length
      @store.length
    end

    def empty?
      @store.empty?
    end

  end
end