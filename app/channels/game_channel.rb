class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_for game
  end

  def receive(data)
    GameChannel.broadcast_to(game, "Player #{current_user} was connected to Game #{params['game']}.")
  end

  private

  def game
    @game ||= Game.find(params['game'])
  end
end
