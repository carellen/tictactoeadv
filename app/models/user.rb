class User < ApplicationRecord
  has_many :matchups
  has_many :games, through: :matchups

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
