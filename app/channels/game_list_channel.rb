class GameListChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'game_list'
  end

  def receive(data)
    ActionCable.server.broadcast("game_list", "GameListChannel connected.")
  end
end
