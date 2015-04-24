module Meli
  class Feedback < Meli::Base
    self.use_oauth = true
    self.prefix= "/feedback/:order_id/"

    cattr_accessor :options

    belongs_to :order, class_name: "Meli::Order"

    def order=(order)
      self.prefix_options[:order_id] = order.id
    end

    def self.default_options
      { "rating"      => "neutral",
        "fulfilled"   => true,
        "reason"      => "",
        "reply"       => "",
        "message"     => "Operação finalizada.",
        "status"      => "ACTIVE" }
    end

    # override by instantiate_record
    def self.instantiate_collection(record, original_params = {}, prefix_options = {})
      instantiate_record record, prefix_options
    end

    def self.find_by_order_id(order_id)
      path    = "/orders/#{order_id}/feedback?version=3.0"
      data    = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    def self.post_feedback(order_id, params = {})
      path    = "/orders/#{order_id}/feedback?version=3.0"
      headers = params
      data    = format.decode(connection.post(path, headers).body)
      instantiate_record data
    end

    def self.post_sale_feedback(order_id, params = {})
      path    = "/orders/#{order_id}/feedback/sale?version=3.0"
      headers = params
      data    = format.decode(connection.put(path, headers).body)
      instantiate_record data
    end

    def self.get_purchase_feedback(order_id)
      path    = "/orders/#{order_id}/feedback/purchase?version=3.0"
      data    = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    def self.post_purchase_feedback(order_id, params = {})
      path    = "/orders/#{order_id}/feedback/purchase?version=3.0"
      headers = params
      data    = format.decode(connection.put(path, headers).body)
      instantiate_record data
    end

    def self.reply_feedback(feedback_id, reply_text)
      path    = "/feedback/#{feedback_id}/reply?version=3.0"
      # headers = params
      headers = {
        "reply"      => reply_text
      }      
      data    = format.decode(connection.post(path, headers).body)
      # instantiate_record data
    end

  end
end
