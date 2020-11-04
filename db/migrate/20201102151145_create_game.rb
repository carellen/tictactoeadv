class CreateGame < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.belongs_to :winner, null: true
      t.string :title, null: false
      t.integer :size, null: false
      t.integer :cell_size
      t.integer :status, null: false, default: 0
      t.boolean :rating, default: false
      t.string :turns, array: true, default: []
      t.string :cells, array: true, default: []
      t.string :win_list, array: true, default: []

      t.timestamps
    end

    add_index :games, :turns, using: :gin
    add_index :games, :cells, using: :gin
    add_index :games, :win_list, using: :gin
  end
end
