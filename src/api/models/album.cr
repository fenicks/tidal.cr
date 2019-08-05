module Tidal::API
  struct Album
    include JSON::Serializable

    getter id : Int32
    getter title : String
    getter duration : Int32

    @[JSON::Field(key: "streamReady")]
    getter stream_ready : Bool

    @[JSON::Field(key: "streamStartDate")]
    getter stream_start_date : String

    @[JSON::Field(key: "allowStreaming")]
    getter allow_streaming : Bool

    @[JSON::Field(key: "premiumStreamingOnly")]
    getter premium_streaming_only : Bool

    @[JSON::Field(key: "numberOfTracks")]
    getter number_of_tracks : Int32

    @[JSON::Field(key: "numberOfVideos")]
    getter number_of_videos : Int32

    @[JSON::Field(key: "numberOfVolumes")]
    getter number_of_volumes : Int32

    @[JSON::Field(key: "releaseDate")]
    getter release_date : String
    getter copyright : String
    getter type : String
    getter version : String?
    getter url : String
    getter cover : String

    @[JSON::Field(key: "videoCover")]
    getter video_cover : String?
    getter explicit : Bool
    getter upc : String
    getter popularity : Int32

    @[JSON::Field(key: "audioQuality")]
    getter audio_quality : String

    @[JSON::Field(key: "surroundTypes")]
    getter surround_types : Array(String)
    getter artist : NamedTuple(id: Int32, name: String, type: String)
    getter artists : Array(NamedTuple(id: Int32, name: String, type: String))
  end
end