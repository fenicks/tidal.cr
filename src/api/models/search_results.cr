require "./artist"

module Tidal::API
  struct SearchResults(T)
    include JSON::Serializable

    getter limit : Int32

    getter offset : Int32

    @[JSON::Field(key: "totalNumberOfItems")]
    getter total_items : Int32

    getter items : Array(T)
  end
end