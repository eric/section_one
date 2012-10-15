module Serious
  class Promise
    class BlockSetError < StandardError; end
    class ValueAlreadySetError < StandardError; end

    alias __class__ class
    instance_methods.each { |m| undef_method m unless m =~ /^__|^object_id$/ }

    def initialize
      @mutex    = Mutex.new
      @resource = ConditionVariable.new
      @written  = false
    end

    def __write__(value)
      case value
      when Exception
        __error__(value)
      else
        __success__(value)
      end
    end

    def __success__(value)
      @mutex.synchronize do
        if @written
          raise ValueAlreadySetError, "Cannot set a value when one has already been set."
        end

        @result  = value
        @written = true

        if @frozen
          freeze
        end

        @resource.broadcast
      end

      self
    end

    def __error__(exception)
      @mutex.synchronize do
        if @written
          raise ValueAlreadySetError, "Cannot set a value when one has already been set."
        end

        @error   = exception
        @written = true

        if @frozen
          freeze
        end

        @resource.broadcast
      end

      self
    end

    def __result__
      @mutex.synchronize do
        until @written
          @resource.wait(@mutex)
        end

        if @error
          raise @error
        end

        return @result
      end
    end

    def freeze
      @frozen = true
      self
    end

    def inspect
      @mutex.synchronize do
        if @result
          @result.inspect
        else
          "#<#{ __class__ }>"
        end
      end
    end

    def marshal_dump
      __result__
      Marshal.dump([ @result, @error, @frozen, @written ])
    end

    def marshal_load(str)
      @mutex = Mutex.new
      @resource = ConditionVariable.new
      @result, @error, @frozen, @written = *Marshal.load(str)
      if @frozen
        freeze
      end
    end

    def respond_to?(message) #:nodoc:
      case message.to_sym
      when :__result__, :__write__, :__success__, :__error__, :inspect, :marshal_dump, :marshal_load, :freeze
        true
      else
        __result__.respond_to?(message)
      end
    end

    def method_missing(*args, &block) #:nodoc:
      __result__.__send__(*args, &block)
    end
  end
end