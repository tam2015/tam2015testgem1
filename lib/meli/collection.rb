
module Meli
  class Collection < ActiveResource::Collection

    cattr_accessor :klass, :name

    extend ActiveModel::Naming
    include CoreExt::Naming

  end
end
