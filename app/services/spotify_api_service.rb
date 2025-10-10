class SpotifyApiService
  def self.get_track_url(...) = new.get_track_url(...)

  def self.get_track_data(...) = new.get_track_data(...)

  def initialize; end

  def get_track_data(track_url)
    track_id = track_url.split("/").last.split("?").first

    response = Faraday.get("https://api.spotify.com/v1/tracks/#{track_id}") do |req|
      req.headers["Authorization"] = "Bearer #{authorize}"
    end
    body = JSON.parse(response.body, symbolize_names: true)

    raise "Track not found" if body[:error]

    {
      title: body[:name],
      artist: body.dig(:artists, 0, :name),
      album: body.dig(:album, :name),
      release_date: body.dig(:album, :release_date)
    }
  end

  def get_track_url(query)
    q = query.map { "#{_1}:#{_2}" }.join(" ")

    response = Faraday.get("https://api.spotify.com/v1/search") do |req|
      req.headers["Authorization"] = "Bearer #{authorize}"
      req.params["q"] = URI.encode_uri_component(q)
      req.params["type"] = "track"
      req.params["limit"] = 1
    end
    body = JSON.parse(response.body, symbolize_names: true)
    track_id = body.dig(:tracks, :items, 0, :id)

    raise "Track not found" unless track_id

    "https://open.spotify.com/track/#{track_id}"
  end

  def authorize
    client = OAuth2::Client.new(
      ENV["SPOTIFY_CLIENT_ID"],
      ENV["SPOTIFY_CLIENT_SECRET"],
      site: "https://accounts.spotify.com",
      token_url: "/api/token"
    )

    client.client_credentials.get_token.token
  end
end
