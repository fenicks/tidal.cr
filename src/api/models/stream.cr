module Tidal::API
  struct Stream
    include JSON::Serializable

    getter url
    getter trackId : Int32
    getter playTimeLeftInMinutes : Int32
    getter soundQuality : String
    getter encryptionKey : String
    getter codec : String

    def initialize(@url, @trackId, @playTimeLeftInMinutes, @soundQuality, @encryptionKey, @codec)
    end
  end
end