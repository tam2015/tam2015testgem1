module Meli
  class Shipment < Meli::Base
    self.use_oauth = true
    self.prefix= "/orders/:order_id/"

    cattr_accessor :possible_status
    self.possible_status = %w(pending handling ready_to_ship shipped delivered not_delivered cancelled )

    belongs_to :order, class_name: "Meli::Order"


    def order=(order)
      self.prefix_options[:order_id] = order.id
    end

    # override by instantiate_record
    def self.instantiate_collection(record, original_params = {}, prefix_options = {})
      puts "\n"
      puts " ==> instantiate_collection \n -> #{record}\n -> #{prefix_options}"
      puts "\n"

      instantiate_record record, prefix_options
    end

  end
end