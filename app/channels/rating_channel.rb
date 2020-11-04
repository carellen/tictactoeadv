class RatingChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'rating'
  end

  def receive(data)
    ActionCable.server.broadcast("rating", "RatingChannel connected.")
  end
end
