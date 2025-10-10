class TrackController < ApplicationController
  def index
    return unless params[:url].present?

    redirect_to MusicUrlTranslationService.call(url: params[:url]), allow_other_host: true
  end
end
