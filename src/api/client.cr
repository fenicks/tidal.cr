require "json"
require "halite"
require "./models/*"

module Tidal::API
  class Client
    enum AudioQuality
      Low
      High
      Lossless
    end

    CONFIG_DEFAULTS = {
      base_url:     "https://api.tidal.com/v1",
      web_token:    "wdgaB1CilGA-S_s2",
      country_code: "US",
      limit:        1000,
    }

    property client : Halite::Client

    getter base_url : String
    getter web_token : String
    getter country_code : String
    getter limit : Int32

    getter params : String
    getter locale_params : String

    getter user_id : Int32? = nil
    getter session_id : String? = nil

    def initialize(
      @base_url = CONFIG_DEFAULTS[:base_url],
      @web_token = CONFIG_DEFAULTS[:web_token],
      @country_code = CONFIG_DEFAULTS[:country_code],
      @limit = CONFIG_DEFAULTS[:limit]
    )
      @client = Halite::Client.new do
        endpoint @base_url
        headers Hash{
          "x-tidal-token" => web_token,
          "Origin"        => "http://listen.tidal.com",
        }
        logging true
      end

      # some base params for GET requests
      @params = "limit=#{limit}&countryCode=#{country_code}"

      # params for Tidal pages that require a locale and device type
      @locale_params = "locale=en_#{country_code}&deviceType=BROWSER&countryCode=#{country_code}"
    end

    def authenticate(username, password)
      data = {username: username, password: password}
      response = request("login/username", method: :post, params: {token: @web_token}, form: data)

      json = response.parse("json")
      @user_id = json["userId"].as_i
      @session_id = json["sessionId"].as_s
      @params = "#{@params}&sessionId=#{@session_id}"

      data
    end

    def get_track_stream_url(track_id, quality = :high)
      assert_authenticated
      stream_quality = quality.to_s.upcase
      raw_params = "soundQuality=#{stream_quality}&countryCode=#{@country_code}&#{@params}"
      response = request("tracks/#{track_id}/streamUrl?#{raw_params}")
      
      json = response.parse("json")
      json["url"].as_s
    end

    def search(query, type : U.class, limit = 25, offset = 0) forall U
      assert_authenticated
      type = case type
      when Artist.class then "artists"
      when Album.class then "albums"
      when Track.class then "tracks"
      when Playlist.class then "playlists"
      else
        raise "type must be one of Artist, Album, Track, or Playlist"
      end

      response = request("search/#{type}", params: {
        query: query,
        limit: limit,
        offset: offset,
        countryCode: @country_code
      })

      SearchResults(U).from_json(response.body)
    end

    def get_track(track_id)
      assert_authenticated
      response = request("tracks/#{track_id}?#{@params}")
      Track.from_json(response.body)
    end

    def get_favorite_tracks
      assert_authenticated
      response = request("users/#{@user_id}/favorites/tracks?#{@params}")
      json = response.parse("json")
      tracks = json["items"].as_a.map(&.["item"])
      Array(Track).from_json(tracks.to_json)
    end

    def get_album(album_id)
      assert_authenticated
      response = request("albums/#{album_id}?#{@params}")
      Album.from_json(response.body)
    end

    def get_album_tracks(album_id)
      assert_authenticated
      response = request("albums/#{album_id}/tracks?#{@params}")
      Array(Track).from_json(response.body)
    end

    def get_featured_albums
      response = request("pages/show_more_featured_albums?#{@locale_params}")
      response.parse("json")
    end

    def get_favorite_albums
      assert_authenticated
      response = request("users/#{@user_id}/favorites/albums?#{@params}")
      json = response.parse("json")
      albums = json["items"].as_a.map(&.["item"])
      Array(Album).from_json(albums.to_json)
    end

    def get_artist(artist_id)
      assert_authenticated
      response = request("artists/#{artist_id}?#{@params}")
      Artist.from_json(response.body)
    end

    def get_artist(artist_id)
      assert_authenticated
      response = request("artists/#{artist_id}/albums?#{@params}")
      Array(Album).from_json(response.body)
    end

    def get_artist_eps_and_singles(artist_id)
      assert_authenticated
      response = request("artists/#{artist_id}?#{@params}")
      Artist.from_json(response.body)
    end

    def get_artist_compilations(artist_id)
      response = request("artists/#{artist_id}/albums?#{@params}&filter=COMPILATIONS")
      Array(Album).from_json(response.body)
    end

    def get_artist_top_tracks(artist_id, limit = 10)
      response = request("artists/#{artist_id}/toptracks?limit=#{limit}&countryCode=#{@countryCode}")
      Array(Track).from_json(response.body)
    end

    def get_similar_artists(artist_id)
      response = request("artists/#{artist_id}/similar?#{@params}")
      Array(Artist).from_json(response.body)
    end

    def get_favorite_artists
      assert_authenticated
      response = request("users/#{@user_id}/favorites/artists?#{@params}")
      json = response.parse("json")
      artists = json["items"].as_a.map(&.["item"])
      Array(Artist).from_json(artists.to_json)
    end

    def get_playlist(uuid)
      response = request("playlists/#{uuid}?#{@params}")
      Playlist.from_json(response.body)
    end

    def get_playlist_tracks(uuid)
      response = request("playlists/#{uuid}/tracks?#{@params}")
      Array(Track).from_json(response.body)
    end

    def get_favorite_playlists
      assert_authenticated
      response = request("users/#{@user_id}/favorites/playlists?#{@params}")
      json = response.parse("json")
      playlists = json["items"].as_a.map(&.["item"])
      Array(Playlist).from_json(playlists.to_json)
    end

    def get_user_playlists
      assert_authenticated
      response = request("users/#{@user_id}/playlists?#{@params}")
      json = response.parse("json")
      playlists = json["items"].as_a.map(&.["item"])
      Array(Playlist).from_json(playlists.to_json)
    end

    def artist_pic_urls(pic_uuid)
      base_url = "https://resources.tidal.com/images/#{pic_uuid.gsub(/-/, '/')}"
      {
        sm: "#{base_url}/160x107.jpg",
        md: "#{base_url}/320x214.jpg",
        lg: "#{base_url}/640x428.jpg"
      }
    end

    def album_art_urls(album_art_uuid)
      base_url = "https://resources.tidal.com/images/#{pic_uuid.gsub(/-/, '/')}"
      {
        sm: "#{base_url}/160x160.jpg",
        md: "#{base_url}/320x320.jpg",
        lg: "#{base_url}/640x640.jpg",
        xl: "#{base_url}/1280x1280.jpg"
      }
    end

    private def request(url, method = :get, params = {} of String => String, form = {} of String => String)
      options = Halite::Options.new(params: params, form: form)
      response = @client.request(method.to_s.upcase, url, options)
      if response.status_code != 200
        raise "Request to #{url} failed"
      end
      response
    end

    private def assert_authenticated
      raise "You must be authenticated to make API calls" unless @user_id && @session_id
    end
  end
end
