module Meli
  class Question < Meli::Base
    self.use_oauth = true
    self.prefix= "/question/:question_id/"

    cattr_accessor :options

    belongs_to :item, class_name: "Meli::Item"

    def self.default_options
      { limit: 50,
        offset: 0,
        pages: -1,
        page:   0 }
    end

    def self.options=(opts)
      @options = default_options.merge(opts)
    end

    def self.options
      unless defined? @options
        @options = default_options
      end
      @options
    end

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
    def self.all_questions(opts={}, &block)
      user_id = options.delete(:user_id) || User.me.id
      opts = options.merge opts
      from = "/my/received_questions/search"
      has_results = true
      questions = []

      while has_results && opts[:pages] != opts[:page] do
        params = {  limit:  opts[:limit],
                    offset: opts[:offset] }

        path = "#{from}#{query_string(params)}"
        data = format.decode(connection.get(path, headers).body) || []


        results = data["questions"]
        has_results = (results.any? and results.count == opts[:limit])

        opts[:page   ] += 1
        opts[:offset ] += opts[:limit]

        yield(results, data, options) if block_given?

        questions.concat results
      end

      unless block_given?
        questions.map! { |question| self.new(question) }
      end

    end

  end
end
