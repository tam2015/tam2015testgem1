module Meli
  class Question < Meli::Base
    self.use_oauth = true
    self.prefix= "/question/:question_id/"

    cattr_accessor :options

    belongs_to :item, class_name: "Meli::Item"

    # override by instantiate_record
    def self.instantiate_collection(record, original_params = {}, prefix_options = {})
      instantiate_record record, prefix_options
    end

    def self.search_by_item_id(item_id)
      path    = "/questions/search?item_id=#{item_id}"
      data    = format.decode(connection.get(path, headers).body)
      instantiate_collection data
    end

    def self.ask_question(item_id, question="")
      path    = "/questions/#{item_id}"
      headers = {
        "text"      => question,
        "item_id"   => item_id
      }
      data    = format.decode(connection.post(path, headers).body)
      instantiate_record data
    end

    def self.answer_question(question_id= "", text="")
      path    = "/answers"
      headers = {
        "question_id" => question_id,
        "text"        => text
      }
      data    = format.decode(connection.post(path, headers).body)
      instantiate_record data
    end

  end
end