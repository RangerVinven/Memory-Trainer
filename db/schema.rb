# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_05_192450) do
  create_table "loci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "memory_palace_id", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["memory_palace_id"], name: "index_loci_on_memory_palace_id"
  end

  create_table "memory_palaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_memory_palaces_on_user_id"
  end

  create_table "pao_cards", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.string "object"
    t.string "person"
    t.integer "rank"
    t.integer "suit"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "suit", "rank"], name: "index_pao_cards_on_user_id_and_suit_and_rank", unique: true
    t.index ["user_id"], name: "index_pao_cards_on_user_id"
  end

  create_table "pao_numbers", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.integer "number"
    t.string "object"
    t.string "person"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "number"], name: "index_pao_numbers_on_user_id_and_number", unique: true
    t.index ["user_id"], name: "index_pao_numbers_on_user_id"
  end

  create_table "training_sessions", force: :cascade do |t|
    t.float "accuracy_percentage"
    t.integer "batch_size"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "duration_seconds"
    t.integer "item_count"
    t.text "recall_data"
    t.integer "status"
    t.text "training_data"
    t.string "training_type"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_training_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "loci", "memory_palaces"
  add_foreign_key "memory_palaces", "users"
  add_foreign_key "pao_cards", "users"
  add_foreign_key "pao_numbers", "users"
  add_foreign_key "training_sessions", "users"
end
