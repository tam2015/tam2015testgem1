module Meli
  class User < Meli::Base
    self.use_oauth = true

    def self.me
      @user ||= find "me"
    end
  end
end
