require "socket"

module Tidal::API
  class Player

    DEFAULT_ARGS = [
      "--input-ipc-server=/tmp/cr-mpv.sock",
      "--idle",
      "--no-video",
      "--no-audio-display",
      "--really-quiet"
    ]
    
    getter? playing : Bool

    getter socket : UNIXSocket

    private getter mpv_process : Process
    private getter mpv_output  : IO::Memory
    private getter mpv_error   : IO::Memory

    def initialize
      validate_mpv
      @playing = false
      @mpv_output = IO::Memory.new
      @mpv_error = IO::Memory.new
      @mpv_process = Process.new("mpv", DEFAULT_ARGS, output: @mpv_output, error: @mpv_error)

      sleep(1)
      @socket = UNIXSocket.new("/tmp/cr-mpv.sock")
    end

    def load_track(url, mode = "replace")
      @socket.puts("loadfile #{url} #{mode}")
      @playing = true
      socket.gets
    end

    def play
      return if playing?
      @socket.puts("keypress p")
      @playing = true
      socket.gets
    end

    def pause
      return unless playing?
      @socket.puts("keypress p")
      @playing = false
      socket.gets
    end

    private def validate_mpv
      res = Process.run("mpv", ["--version"])
      raise "Please install mpv to use the player" unless res.success?
    end
  end
end