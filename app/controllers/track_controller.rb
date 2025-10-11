class TrackController < ApplicationController
  def index
    @url = params[:url]

    return unless @url.present?

    redirect_to MusicUrlTranslationService.call(url: @url), allow_other_host: true
  rescue StandardError => e
    @error = e.message
  end

  def share
    return redirect_to root_path unless params[:url].present?

    @share_url = MusicUrlTranslationService.call(url: params[:url])
  rescue StandardError => e
    @error = e.message
    @url = params[:url]
    render :index
  end
end
