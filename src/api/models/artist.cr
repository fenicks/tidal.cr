module Tidal::API
  struct Artist
    include JSON::Serializable

    getter id : Int32

    getter name : String

    @[JSON::Field(key: "artistTypes")]
    getter artist_types : Array(String)

    getter url : String

    getter picture : String?

    getter popularity : Int32
  end
end