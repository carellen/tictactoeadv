class GameComponent < ViewComponent::Base
  def initialize(player: nil, message: nil)
    @current_player = player
    @message = message
    @color = @current_player == 'x' ? 'red' : 'blue'
  end
end
