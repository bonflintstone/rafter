class DeezerApiService
  def self.get_track_url(...) = new.get_track_url(...)

  def self.get_track_data(...) = new.get_track_data(...)

  def initialize; end

  def get_track_data(track_url)
    track_url = resolve_share_link(track_url) if track_url.include?("link.deezer.com")
    track_id = track_url[%r{/track/(\d+)}, 1]

    raise "Unsupported Deezer URL" unless track_id

    response = Faraday.get("https://api.deezer.com/track/#{track_id}")
    body = JSON.parse(response.body, symbolize_names: true)

    raise "Track not found" if body[:error]

    {
      title: body[:title],
      artist: body.dig(:artist, :name),
      album: body.dig(:album, :title),
      release_date: body.dig(:album, :release_date),
      isrc: body[:isrc]
    }
  end

  def get_track_url(query)
    find_by_isrc(query[:isrc]) ||
      search(%(track:"#{query[:title]}" artist:"#{query[:artist]}")) ||
      search([query[:title], query[:artist]].compact.join(" ")) ||
      raise("Track not found")
  end

  private

  def find_by_isrc(isrc)
    return if isrc.blank?

    response = Faraday.get("https://api.deezer.com/track/isrc:#{isrc}")
    body = JSON.parse(response.body, symbolize_names: true)

    body[:link] unless body[:error]
  end

  def search(q)
    response = Faraday.get("https://api.deezer.com/search") do |req|
      req.params["q"] = q
      req.params["limit"] = 1
    end
    body = JSON.parse(response.body, symbolize_names: true)

    body[:data]&.find { _1[:type] == "track" }&.dig(:link)
  end

  def resolve_share_link(url)
    response = Faraday.get(url)
    location = response.headers["location"]
    raise "Could not resolve share link" if location.blank?

    dest = Rack::Utils.parse_query(URI.parse(location).query.to_s)["dest"]
    dest.presence || location
  rescue Faraday::Error, URI::InvalidURIError
    raise "Could not resolve share link"
  end
end
