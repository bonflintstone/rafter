class SpotifyApiService
  def self.get_track_url(...) = new.get_track_url(...)

  def self.get_track_data(...) = new.get_track_data(...)

  def initialize; end

  def get_track_data(track_url)
    track_id = track_url[%r{/track/([A-Za-z0-9]+)}, 1]

    raise "Unsupported Spotify URL" unless track_id

    response = Faraday.get("https://api.spotify.com/v1/tracks/#{track_id}") do |req|
      req.headers["Authorization"] = "Bearer #{token}"
    end
    body = JSON.parse(response.body, symbolize_names: true)

    raise "Track not found" if body[:error]

    {
      title: body[:name],
      artist: body.dig(:artists, 0, :name),
      album: body.dig(:album, :name),
      release_date: body.dig(:album, :release_date),
      isrc: body.dig(:external_ids, :isrc)
    }
  end

  def get_track_url(query)
    track_id =
      (query[:isrc].present? && search("isrc:#{query[:isrc]}")) ||
      search(%(track:"#{query[:title]}" artist:"#{query[:artist]}")) ||
      search([query[:title], query[:artist]].compact.join(" "))

    raise "Track not found" unless track_id

    "https://open.spotify.com/track/#{track_id}"
  end

  private

  def search(q)
    response = Faraday.get("https://api.spotify.com/v1/search") do |req|
      req.headers["Authorization"] = "Bearer #{token}"
      req.params["q"] = q
      req.params["type"] = "track"
      req.params["limit"] = 1
    end
    body = JSON.parse(response.body, symbolize_names: true)

    body.dig(:tracks, :items, 0, :id)
  end

  def token
    @token ||= OAuth2::Client.new(
      ENV["SPOTIFY_CLIENT_ID"],
      ENV["SPOTIFY_CLIENT_SECRET"],
      site: "https://accounts.spotify.com",
      token_url: "/api/token"
    ).client_credentials.get_token.token
  end
end
