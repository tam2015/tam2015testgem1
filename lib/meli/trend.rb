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

  end
end


