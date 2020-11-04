class PagesController < ApplicationController
  def index
    # @game = current_game
  end

  private

  def current_game
    (current_user && current_user.games.active.last) || Rails.cache.fetch("game:#{session.id}:active")
  end
end