class RatingComponent < ViewComponent::Base
  def initialize
    @players = User.all.order(rating: :desc).take(20)
  end
end
