class VideoDecorator < Draper::Decorator
  delegate_all

  def rating
    object.reviews.present? ? "#{object.calculate_rating} / 5.0" : "Be the first to rate this video!"
  end
end