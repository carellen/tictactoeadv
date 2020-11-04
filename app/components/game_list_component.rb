class GameListComponent < ViewComponent::Base
  delegate :current_user, to: :helpers
  def initialize
    @games = Game.active.order(created_at: :desc)
  end
end
