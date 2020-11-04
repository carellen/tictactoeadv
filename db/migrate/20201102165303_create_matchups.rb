class CreateMatchups < ActiveRecord::Migration[6.0]
  def change
    create_table :matchups do |t|
      t.belongs_to :game
      t.belongs_to :user
      t.integer :mark
    end
  end
end
