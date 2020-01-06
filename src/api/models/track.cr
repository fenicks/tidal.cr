module Tidal::API
  struct Track
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    getter id : Int32
    getter title : String
    getter duration : Int32
    getter replayGain : Float64
    getter peak : Float64

    @[JSON::Field(key: "allowStreaming")]
    getter allow_streaming : Bool
    
    @[JSON::Field(key: "streamReady")]
    getter stream_ready : Bool
    
    @[JSON::Field(key: "streamStartDate")]
    getter stream_start_date : String
    
    @[JSON::Field(key: "premiumStreamingOnly")]
    getter premium_streaming_only : Bool
    
    @[JSON::Field(key: "trackNumber")]
    getter track_number : Int32
    
    @[JSON::Field(key: "volumeNumber")]
    getter volume_number : Int32
    getter version : String?
    getter popularity : Int32
    getter copyright : String
    getter url : String
    getter isrc : String
    getter editable : Bool
    getter explicit : Bool
    
    @[JSON::Field(key: "audioQuality")]
    getter audio_quality : String
    
    @[JSON::Field(key: "surroundTypes")]
    getter surround_types : Array(String)?
    getter artist : NamedTuple(id: Int32, name: String, type: String)
    getter artists : Array(NamedTuple(id: Int32, name: String, type: String))
    getter album : NamedTuple(id: Int32, title: String, cover: String)
  end
end