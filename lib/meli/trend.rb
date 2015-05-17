module Meli
  class Trend < Meli::Base
    self.use_oauth = false


    def self.find(site_id)
      path = "/sites/#{site_id}/trends/search"
      data = format.decode(connection.get(path, headers).body)
      instantiate_collection data
    end


    def self.find_by_category_id(site_id, category_id)
      path = "/sites/#{site_id}/trends/search?category=#{category_id}"
      data = format.decode(connection.get(path, headers).body)
      instantiate_collection data
    end

    def self.shipping_calculator(seller_zip_code, customer_zip_code, dimension)
      path = "/sites/MLB/shipping_options?zip_code_from=#{seller_zip_code}&zip_code_to=#{customer_zip_code}&dimensions=#{dimension}"
      data = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end    


  end
end


