class MusicUrlTranslationService
  SUPPORTED_PLATFORMS = %w[spotify deezer].freeze

  def self.call(...) = new.call(...)

  def initialize; end

  def call(url:, target: nil)
    source = SUPPORTED_PLATFORMS.find { url.include?(_1) }
    target ||= (SUPPORTED_PLATFORMS - [source]).first

    raise "Unsupported source platform" unless SUPPORTED_PLATFORMS.include?(source)
    raise "Unsupported target platform" unless SUPPORTED_PLATFORMS.include?(target)

    source_service = Object.const_get("#{source.capitalize}ApiService")
    target_service = Object.const_get("#{target.capitalize}ApiService")

    track_data = source_service.get_track_data(url)
    target_service.get_track_url(track_data)
  end
end
