module Tidal::API
  struct Playlist
    include JSON::Serializable

    getter uuid : String
    getter title : String

    @[JSON::Field(key: "numberOfTracks")]
    getter number_of_tracks : Int32
    
    @[JSON::Field(key: "numberOfVideos")]
    getter number_of_videos : Int32
    getter creator : NamedTuple(id: Int32)
    getter description : String
    getter duration : Int32
    
    @[JSON::Field(key: "lastUpdated")]
    getter last_updated : String
    getter created : String
    getter type : String
    
    @[JSON::Field(key: "publicPlaylist")]
    getter public_playlist : Bool
    getter url : String
    getter image : String
    getter popularity : Int32
    
    @[JSON::Field(key: "squareImage")]
    getter square_image : String
  end
end