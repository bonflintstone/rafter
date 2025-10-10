class DeezerApiService
  def self.get_track_url(...) = new.get_track_url(...)

  def self.get_track_data(...) = new.get_track_data(...)

  def initialize; end

  def get_track_data(track_url)
    track_id = track_url.split("/").last.split("?").first

    response = Faraday.get("https://api.deezer.com/track/#{track_id}")
    body = JSON.parse(response.body, symbolize_names: true)

    raise "Track not found" if body[:error]

    {
      title: body[:title],
      artist: body.dig(:artist, :name),
      album: body.dig(:album, :title),
      release_date: body.dig(:album, :release_date)
    }
  end

  def get_track_url(query)
    query = query.slice(:title, :artist, :album).compact

    response = Faraday.get("https://api.deezer.com/search") do |req|
      req.params["q"] = URI.encode_uri_component(query.values.join(" "))
      req.params["limit"] = 1
    end
    body = JSON.parse(response.body, symbolize_names: true)

    track_url = body[:data].find { it[:type] == 'track' }&.then { it[:link] }

    raise "Track not found" unless track_url

    track_url
  end
end
