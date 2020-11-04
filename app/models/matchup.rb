class Matchup < ApplicationRecord
  belongs_to :game
  belongs_to :user

  enum mark: { x: 0, o: 1 }

  before_create :seed

  def seed
    if game.matchups.size == 1
      self.mark = self.class.marks.keys.sample
    else
      self.mark = game.matchups.first.mark == :x ? :o : :x
    end
  end
end