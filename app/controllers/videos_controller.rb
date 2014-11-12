class VideosController < ApplicationController
  before_action :require_user

  def index
    @categories = Category.all
  end

  def show
    @video = VideoDecorator.decorate(Video.find(params[:id]))
    @review = Review.new
  end

  def search
    @videos = Video.search_by_title(params[:search])
  end
end