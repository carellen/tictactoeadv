# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_04_143825) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.bigint "winner_id"
    t.string "title", null: false
    t.integer "size", null: false
    t.integer "cell_size"
    t.integer "status", default: 0, null: false
    t.boolean "rating", default: false
    t.string "turns", default: [], array: true
    t.string "cells", default: [], array: true
    t.string "win_list", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cells"], name: "index_games_on_cells", using: :gin
    t.index ["turns"], name: "index_games_on_turns", using: :gin
    t.index ["win_list"], name: "index_games_on_win_list", using: :gin
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "matchups", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "user_id"
    t.integer "mark"
    t.index ["game_id"], name: "index_matchups_on_game_id"
    t.index ["user_id"], name: "index_matchups_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "rating", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
