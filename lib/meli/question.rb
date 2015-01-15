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

    # GET /questions/{Question_id}
    def self.find(question_id)
      path    = "/questions/#{item_id}"
      data    = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # GET /questions/{Item_id}
    def self.find_by_item_id(item_id)
      path    = "/questions/search?item_id=#{item_id}"
      data    = format.decode(connection.get(path, headers).body)
      instantiate_record data
    end

    # POST /questions/{Item_id}
    def self.ask_question(item_id, question="")
      path    = "/questions/#{item_id}"
      headers = {
        "text"      => question,
        "item_id"   => item_id
      }
      data    = format.decode(connection.post(path, headers).body)
      instantiate_record data
    end

    # GET /answers
    def self.answer_question(question_id="", text="")
      path    = "/answers"
      headers = {
        "question_id" => question_id,
        "text"        => text
      }
      data    = format.decode(connection.post(path, headers).body)
      instantiate_record data
    end

    # GET /users/{Seller_id}/questions_blacklist
    def self.list_blacklist(user_id)
      path    = "/users/#{user_id}/questions_blacklist"
      data    = format.decode(connection.get(path, headers).body)
      instantiate_collection data
    end

    # POST /users/{Seller_id}/questions_blacklist
     def self.add_user_to_blacklist(user_id)
      path    = "/users/#{user_id}/questions_blacklist"
      headers = {
        "user_id"   => user_id
      }
      data    = format.decode(connection.post(path, headers).body)
      instantiate_collection data
    end

    # DELETE /users/{Seller_id}/questions_blacklist
    def self.remove_user_from_blacklist(user_id)
      path    = "/users/#{user_id}/questions_blacklist"
      headers = {
        "user_id"   => user_id
      }
      data    = format.decode(connection.delete(path, headers).body)
      instantiate_collection data
    end

    # GET /my/received_questions/search
    def self.all_my_questions(user_id)
      path    = "/my/received_questions/search"
      data    = format.decode(connection.get(path, headers).body)
      instantiate_collection data
    end

  end
end
