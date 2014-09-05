module Meli
  class Description < Meli::Base
    self.use_oauth = true
    self.prefix= "/items/:item_id/"

    # belongs_to :item, class_name: "Meli::Item"

    def item=(item)
      self.prefix_options[:item_id] = item.id
    end

    # # override by instantiate_record
    # def self.instantiate_collection(record, original_params = {}, prefix_options = {})
    #   puts "\n"
    #   puts " ==> instantiate_collection \n -> #{record}\n -> #{prefix_options}"
    #   puts "\n"

    #   instantiate_record record, prefix_options
    # end

  end
end
