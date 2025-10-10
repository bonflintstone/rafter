class TrackController < ApplicationController
  def index
    return unless params[:url].present?

    redirect_to MusicUrlTranslationService.call(url: params[:url]), allow_other_host: true
  rescue StandardError => e
    @error = e.message
  end
end
