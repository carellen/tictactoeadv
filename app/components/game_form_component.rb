class GameFormComponent < ViewComponent::Base
  def initialize(game_id: nil, message: nil)
    @game_id = game_id
    @message = message
  end
end
