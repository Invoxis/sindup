module Sindup
  class CollectFilter < Internal::Base

    def initialize(options = {}, &block)
      puts "initializing a new #{self.class.name}"
      yield self if block_given?
    end

  end # !CollectFilter

  # class CollectFilterNews < CollectFilter; end
  # class CollectFilterForums < CollectFilter; end
  # class CollectFilterSocialNetworks < CollectFilter; end
  # class CollectFilterOpinions < CollectFilter; end
  # class CollectFilterDocuments < CollectFilter; end
end # !Sindup
