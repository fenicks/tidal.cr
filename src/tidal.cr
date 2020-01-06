require "./api/client"
require "./api/player"

cli = Tidal::API::Client.new
# cli.authenticate("cawatson1993@gmail.com", "Pi31415926!")
cli.load_session

artists = cli.search("Matchbox Twenty", Tidal::API::Artist, limit: 5)
billie = artists.items[0]

top_tracks = cli.get_artist_top_tracks(billie.id, 1)
top_song = top_tracks.items[0]

stream_url = cli.get_track_stream_url(top_song.id)
pp stream_url
