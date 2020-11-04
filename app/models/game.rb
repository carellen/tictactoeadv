class Game < ApplicationRecord
  belongs_to :winner, class_name: 'User', optional: true
  has_many :matchups
  has_many :players, through: :matchups, source: :user

  X_COORDINATES = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z).freeze
  Y_COORDINATES = %w(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25).freeze

  enum status: { waiting_opponent: 0, in_progress: 1, finished: 2, canceled: 9 }

  validates :title, :size, presence: true

  after_initialize :set_defaults

  scope :free, -> { where(rating: false) }
  scope :rating, -> { where(rating: true) }
  scope :active, -> { where(status: [:waiting_opponent, :in_progress]) }

  def set_defaults
    self.cell_size = self.class.cell_size(size)
    self.cells = self.class.cells_for(size)
    self.win_list = self.class.win_list_for(size)
  end

  class << self

    def cell_size(size)
      case size
      when 0..7 then 12
      when 7..10 then 8
      when 10..20 then 5
      else 4
      end
    end

    def cells_for(size)
      X_COORDINATES[0...size].map do |x|
        Y_COORDINATES[0...size].map do |y|
          "#{x}-#{y}"
        end
      end
    end

    def possible_combinations_for(size)
      size * (size - 4) * 2 + 2*(size - 4)**2
    end

    def win_list_for(size)
      cells = cells_for(size)

      cols = cells.flat_map do |col|
        col.each_cons(5).to_a
      end

      rows = cells.transpose.flat_map do |col|
        col.each_cons(5).to_a
      end

      main_diag = (0...size).map.with_index do |step, index|
        "#{X_COORDINATES[step]}-#{Y_COORDINATES[index]}"
      end

      main_diag_rev = (0...size).to_a.reverse.map.with_index do |step, index|
        "#{X_COORDINATES[step]}-#{Y_COORDINATES[index]}"
      end

      add_diags = []

      (size - 5).times do |s|
        offcet = s + 1
        add_diags << (0...(size - offcet)).map.with_index do |step, index|
          "#{X_COORDINATES[step]}-#{Y_COORDINATES[index + offcet]}"
        end
        add_diags << (0...(size - offcet)).map.with_index do |step, index|
          "#{X_COORDINATES[step + offcet]}-#{Y_COORDINATES[index]}"
        end
        add_diags << (0...(size - offcet)).to_a.reverse.map.with_index do |step, index|
          "#{X_COORDINATES[step]}-#{Y_COORDINATES[index]}"
        end
        add_diags << (0...(size - offcet)).to_a.reverse.map.with_index do |step, index|
          "#{X_COORDINATES[step + offcet]}-#{Y_COORDINATES[index + offcet]}"
        end
      end

      diags = [main_diag, main_diag_rev, *add_diags].flat_map do |col|
        col.each_cons(5).to_a
      end

      [*rows, *cols, *diags]
    end
  end
end