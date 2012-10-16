require 'serious/promise'

module Serious
  extend self

  def promise
    ::Serious::Promise.new
  end

  def future(*args, &block)
    promise = ::Serious::Promise.new

    Thread.new(promise, args, block) do |promise, args, block|
      begin
        promise.__success__(block.call(*args))
      rescue Exception => e
        promise.__error__(e)
      end
    end

    promise
  end

  def demand(promise)
    if promise.respond_to? :__result__
      promise.__result__
    else # not really a promise
      promise
    end
  end
end