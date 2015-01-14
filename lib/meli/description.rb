module Meli
  class Description < Meli::Base
    self.use_oauth = true
    self.prefix= "/items/:item_id/"

    def item=(item)
      self.prefix_options[:item_id] = item.id
    end

  end
end
