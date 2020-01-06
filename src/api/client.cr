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

    DEFAULT_ENDPOINT = "https://api.tidalhifi.com/v1/"
    LOSSY_TOKEN = "4zx46pyr9o8qZNRw"
    LOSSLESS_TOKEN = "kgsOOmYk3zShYrNP"

    getter country_code : String
    getter limit : Int32
    getter quality : AudioQuality

    getter user_id : Int32? = nil
    getter session_id : String? = nil

    def initialize(
      @country_code : String = "US",
      @limit : Int32 = 1000,
      @quality : AudioQuality = AudioQuality::High
    )
    end

    def authenticate(username, password)
      data = {username: username, password: password}
      response = request("login/username", method: :post, params: {token: @lossy_token}, form: data)

      json = response.parse("json")
      @user_id = json["userId"].as_i
      @session_id = json["sessionId"].as_s

      data
    end

    def save_session(output_file = "./tidal.session")
      assert_authenticated
      output = {user_id: @user_id, session_id: @session_id}.to_json
      File.write(output_file, output)
      output_file
    end

    def load_session(filename = "./tidal.session")
      input = File.read(filename)
      data = JSON.parse(input)
      @user_id, @session_id = data["user_id"].as_i, data["session_id"].as_s
      self
    rescue e
      raise "Failed to load session data from '#{filename}'"
    end

    def get_track_stream_url(track_id)
      assert_authenticated
      stream_quality = @quality.to_s.upcase
      response = request("tracks/#{track_id}/streamUrl", params: {soundQuality: stream_quality})

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
      response = request("tracks/#{track_id}")
      Track.from_json(response.body)
    end

    def get_favorite_tracks
      assert_authenticated
      response = request("users/#{@user_id}/favorites/tracks")
      json = response.parse("json")
      tracks = json["items"].as_a.map(&.["item"])
      Array(Track).from_json(tracks.to_json)
    end

    def get_album(album_id)
      assert_authenticated
      response = request("albums/#{album_id}")
      Album.from_json(response.body)
    end

    def get_album_tracks(album_id)
      assert_authenticated
      response = request("albums/#{album_id}/tracks")
      Array(Track).from_json(response.body)
    end

    def get_featured_albums
      response = request("pages/show_more_featured_albums")
      response.parse("json")
    end

    def get_favorite_albums
      assert_authenticated
      response = request("users/#{@user_id}/favorites/albums")
      json = response.parse("json")
      albums = json["items"].as_a.map(&.["item"])
      Array(Album).from_json(albums.to_json)
    end

    def get_artist(artist_id)
      assert_authenticated
      response = request("artists/#{artist_id}")
      Artist.from_json(response.body)
    end

    def get_artist(artist_id)
      assert_authenticated
      response = request("artists/#{artist_id}/albums")
      Array(Album).from_json(response.body)
    end

    def get_artist_eps_and_singles(artist_id)
      assert_authenticated
      response = request("artists/#{artist_id}")
      Artist.from_json(response.body)
    end

    def get_artist_compilations(artist_id)
      response = request("artists/#{artist_id}/albums", params: {filter: "COMPILATIONS"})
      Array(Album).from_json(response.body)
    end

    def get_artist_top_tracks(artist_id, limit = 10)
      response = request("artists/#{artist_id}/toptracks", params: {limit: limit})
      SearchResults(Track).from_json(response.body)
    end

    def get_similar_artists(artist_id)
      response = request("artists/#{artist_id}/similar")
      Array(Artist).from_json(response.body)
    end

    def get_favorite_artists
      assert_authenticated
      response = request("users/#{@user_id}/favorites/artists")
      json = response.parse("json")
      artists = json["items"].as_a.map(&.["item"])
      Array(Artist).from_json(artists.to_json)
    end

    def get_playlist(uuid)
      response = request("playlists/#{uuid}")
      Playlist.from_json(response.body)
    end

    def get_playlist_tracks(uuid)
      response = request("playlists/#{uuid}/tracks")
      Array(Track).from_json(response.body)
    end

    def get_favorite_playlists
      assert_authenticated
      response = request("users/#{@user_id}/favorites/playlists")
      json = response.parse("json")
      playlists = json["items"].as_a.map(&.["item"])
      Array(Playlist).from_json(playlists.to_json)
    end

    def get_user_playlists
      assert_authenticated
      response = request("users/#{@user_id}/playlists")
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

    def request(path, method = :get, params = {} of String => String, form = {} of String => String)
      headers = {
        "x-tidal-token" => @quality == AudioQuality::Lossless ? LOSSLESS_TOKEN : LOSSY_TOKEN,
        "Origin"        => "http://listen.tidal.com",
      }

      params = {
        sessionId: @session_id,
        countryCode: @country_code,
        limit: @limit
      }.merge(params)

      url = File.join(DEFAULT_ENDPOINT, path)
      options = Halite::Options.new(params: params, form: form, headers: headers)
      response = Halite.request(method.to_s.upcase, url, options)

      unless (200...300).includes?(response.status_code)
        raise "Request to #{url} failed with status #{response.status_code}"
      end

      response
    end

    private def assert_authenticated
      raise "You must be authenticated to make API calls" unless @user_id && @session_id
    end
  end
end
