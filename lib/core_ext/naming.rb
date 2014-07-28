module CoreExt
  module Naming
    module ClassMethods

      # Override @name of model
      # ---- Example:
      #     Person.name                 # => Person
      #
      #     # set model name to "OtherPerson"
      #     Person.name= "OtherPerson"  # => Person
      #     Person.name                 # => OtherPerson

      attr_accessor(:klass ) { self  }

      def name
        @name || super
      end

      def name=(new_name)
        @name = model_name(new_name)
      end

      def model_name(new_name=nil)
        @model_name = nil if new_name

        @model_name ||= begin
          # namespace = self.parents.detect do |n|
          #   n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
          # end
          # ActiveModel::Name.new(self, namespace, new_name)
          ActiveModel::Name.new(self, nil, new_name)
        end
      end
    end

    module InstanceMethods
      def initialize(*args)
        super(*args)

        # delegate :model_name and :name to class without attributes with keys
        class_eval { delegate :model_name , to: :class } unless respond_to? :model_name
        class_eval { delegate :name       , to: :class } unless respond_to? :name
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
