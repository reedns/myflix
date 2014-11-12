class ReviewsController < ApplicationController
  before_action :require_user

  def create
    @video = VideoDecorator.decorate(Video.find(params[:video_id]))
    @review = @video.reviews.new(review_params)
    @review.creator = current_user
    
    if @review.save
      flash[:success] = "Review saved!"
      redirect_to video_path(@video)
    else
      flash[:danger] = "Something went wrong."
      @video.reviews.reload
      render "videos/show"
    end
  end
end

private

def review_params
  params.require(:review).permit(:body, :rating)
end