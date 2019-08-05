# Tidal.cr

Unofficial Tidal API client for Crystal. Tidal.cr allows you to utilize Tidal's completely undocumented API to lookup artists, tracks, albums, and playlists, as well as get the stream URL for tracks. This is a work in progress and will eventually include a full CLI that utilizes mpv to play tracks.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     tidal:
       github: watzon/tidal
   ```

2. Run `shards install`

## Usage

```crystal
require "tidal"
```

TODO: Write usage instructions here

## Contributing

1. Fork it (<https://github.com/watzon/tidal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Watson](https://github.com/watzon) - creator and maintainer
