module Meli
  class Shipment < Meli::Base
    self.use_oauth = true
    self.prefix= "/orders/:order_id/"

    cattr_accessor :options
    cattr_accessor :possible_status
    self.possible_status = %w(pending handling ready_to_ship shipped delivered not_delivered cancelled )

    belongs_to :order, class_name: "Meli::Order"

    def order=(order)
      self.prefix_options[:order_id] = order.id
    end

    # override by instantiate_record
    def self.instantiate_collection(record, original_params = {}, prefix_options = {})
      instantiate_record record, prefix_options
    end

    # GET /shipments/{Shipment_id}
    def self.find(shipment_id)
      path = "/shipments/#{shipment_id}"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

   # PUT /shipments/{Shipment_id}
    def self.set_delivered!(shipment_id)
      path = "/shipments/#{shipment_id}"
      headers = {
        "status" => "delivered"
      }
      data = format.decode(connection.put(path, headers).body)
      instantiate_record data
    end

    # GET /items/{Item_id}/shipping_options
    def self.options_by_item_id(item_id = "")
      path = "/items/#{item_id}/shipping_options"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # GET /sites/{Site_id}/shipping_methods
    def self.methods_by_item_id(item_id = "")
      path = "/items/#{item_id}/shipping_methods"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # GET /sites/{Site_id}/shipping_services
    def self.services_by_item_id(item_id = "")
      path = "/items/#{item_id}/shipping_services"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # /sites/{Site_id}/shipping_options?zip_code_from={Zip_code}&zip_code_to={Zip_code}&dimensions={Dimensions}
    def self.calculate_cost_by_site_id(site_id, zip_code_from, zip_code_to, dimensions, weight)
      path = "/sites/#{site_id}/shipping_options"
      array_path = [
        path,
        "?zip_code_from=#{zip_code_from}",
        "&zip_code_to=#{zip_code_to}",
        "&dimensions=#{dimensions}",
        ",#{weight}"
      ]
      path = array_path.join("")
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # /users/{Cust_id}/shipping_modes?category_id={Category_id}
    def self.available_category_filters_for_customer(customer_id, category_id)
      path = "/users/#{customer_id}/shipping_modes?category_id=#{category_id}"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # /users/{Cust_id}/shipping_options?zip_code={Zip_code}&dimensions={Dimensions}
    def self.calculate_cost(customer_id, zip_code, dimensions, weight)
      path = "/sites/#{customer_id}/shipping_options"
      array_path = [
        path,
        "?zip_code=#{zip_code}",
        "&dimensions=#{dimensions}",
        ",#{weight}"
      ]
      path = array_path.join("")
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # /users/{Cust_id}/shipping_preferences
    def self.user_preferences(customer_id)
      path = "/users/#{customer_id}/shipping_preferences"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # /orders/{Order_id}/shipments
    def self.find_by_order_id(order_id)
      path = "/orders/#{order_id}/shipments"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # /shipment_labels
    def self.print_label(save_pdf = "Y", *shipment_ids)
      shipment_ids_str = shipment_ids.join(",")
      path = "/shipment_labels?shipment_ids=#{shipment_ids_str}"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    def self.shipping_calculator(seller_zip_code, customer_zip_code, dimension)
      self.use_oauth = false
      path = "/sites/MLB/shipping_options?zip_code_from=#{seller_zip_code}&zip_code_to=#{customer_zip_code}&dimensions=#{dimension}"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end    


  end
end
