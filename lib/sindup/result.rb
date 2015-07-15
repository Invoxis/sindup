module Sindup
  class Result < Internal::Base

    def initialize(args, &block)
      puts "initializing a new #{self.class.name} with [#{args.join(', ')}]"
      yield self if block_given?
    end

    module ClassMethods
    end # !ClassMethods
    extend ClassMethods

  end # !Result
end # !Sindup
