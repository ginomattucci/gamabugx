# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161024184959) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "auction_attempts", force: :cascade do |t|
    t.integer  "auction_id"
    t.integer  "user_id"
    t.integer  "credits"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "auction_attempts", ["auction_id"], name: "index_auction_attempts_on_auction_id", using: :btree
  add_index "auction_attempts", ["user_id"], name: "index_auction_attempts_on_user_id", using: :btree

  create_table "auction_bids", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "auction_id"
    t.integer  "value_in_credits"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "auction_attempt_id"
  end

  add_index "auction_bids", ["auction_attempt_id"], name: "index_auction_bids_on_auction_attempt_id", using: :btree
  add_index "auction_bids", ["auction_id"], name: "index_auction_bids_on_auction_id", using: :btree
  add_index "auction_bids", ["user_id"], name: "index_auction_bids_on_user_id", using: :btree

  create_table "auctions", force: :cascade do |t|
    t.string   "title"
    t.string   "image"
    t.string   "description_url"
    t.datetime "happens_at"
    t.integer  "countdown_timer",      limit: 8, default: 10
    t.integer  "winner_id"
    t.decimal  "final_cost",                     default: 0.0
    t.datetime "ended_at"
    t.integer  "bid_cost_in_credits",            default: 1
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.decimal  "market_price"
    t.text     "description"
    t.boolean  "canceled",                       default: false
    t.integer  "increase_value",                 default: 1
    t.integer  "join_cost_in_credits"
    t.boolean  "tournament",                     default: false
    t.integer  "max_attempts"
    t.integer  "players"
    t.integer  "credits_by_attempt"
    t.string   "second_image"
  end

  create_table "banners", force: :cascade do |t|
    t.string   "image"
    t.string   "url"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "best_guess_attempts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "best_guess_id"
    t.datetime "finished_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "score",            default: 0
    t.integer  "value_in_credits"
    t.datetime "started_at"
  end

  add_index "best_guess_attempts", ["best_guess_id"], name: "index_best_guess_attempts_on_best_guess_id", using: :btree
  add_index "best_guess_attempts", ["user_id"], name: "index_best_guess_attempts_on_user_id", using: :btree

  create_table "best_guesses", force: :cascade do |t|
    t.string   "title"
    t.datetime "happens_at"
    t.datetime "ends_at"
    t.string   "image"
    t.string   "description_url"
    t.integer  "join_cost_in_credits",           default: 10
    t.integer  "winner_id"
    t.text     "question"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.decimal  "final_cost",                     default: 0.0
    t.string   "category"
    t.decimal  "market_price"
    t.text     "description"
    t.integer  "increase_value",                 default: 1
    t.string   "second_image"
    t.boolean  "tournament",                     default: false
    t.integer  "players"
    t.integer  "duration_time",        limit: 8
  end

  add_index "best_guesses", ["winner_id"], name: "index_best_guesses_on_winner_id", using: :btree

  create_table "highlights", force: :cascade do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "plans", force: :cascade do |t|
    t.integer  "credits"
    t.decimal  "price"
    t.string   "title"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prize_claims", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "status",          default: 0
    t.string   "full_name"
    t.string   "deliver_address"
    t.string   "phone_number"
    t.date     "shipped_on"
    t.text     "notes"
    t.string   "tracking_code"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "cpf"
    t.string   "neighborhood"
    t.string   "city"
    t.string   "uf"
    t.string   "country"
    t.string   "zip_code"
  end

  add_index "prize_claims", ["user_id"], name: "index_prize_claims_on_user_id", using: :btree

  create_table "purchases", force: :cascade do |t|
    t.integer  "plan_id"
    t.integer  "user_id"
    t.string   "plan_name"
    t.integer  "plan_credits"
    t.decimal  "plan_price"
    t.string   "status"
    t.string   "invoice"
    t.string   "invoice_url"
    t.string   "payment_method"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "fullname"
    t.string   "cpf"
    t.string   "address"
    t.string   "neighborhood"
    t.string   "city"
    t.string   "uf"
    t.string   "country"
    t.string   "zip_code"
    t.string   "phone"
  end

  add_index "purchases", ["plan_id"], name: "index_purchases_on_plan_id", using: :btree
  add_index "purchases", ["user_id"], name: "index_purchases_on_user_id", using: :btree

  create_table "statement_answers", force: :cascade do |t|
    t.boolean  "value"
    t.integer  "best_guess_attempt_id"
    t.integer  "statement_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "statement_answers", ["best_guess_attempt_id"], name: "index_statement_answers_on_best_guess_attempt_id", using: :btree
  add_index "statement_answers", ["statement_id"], name: "index_statement_answers_on_statement_id", using: :btree

  create_table "statements", force: :cascade do |t|
    t.integer  "best_guess_id"
    t.text     "content"
    t.string   "image"
    t.boolean  "answer"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "statements", ["best_guess_id"], name: "index_statements_on_best_guess_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "blocked",                default: false
    t.integer  "credits",                default: 5
    t.string   "username",                               null: false
    t.string   "address"
    t.string   "cpf"
    t.string   "document_id"
    t.date     "birthday"
    t.string   "city"
    t.string   "country"
    t.string   "fullname"
    t.string   "neighborhood"
    t.string   "phone"
    t.string   "uf"
    t.string   "zip_code"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "auction_attempts", "auctions"
  add_foreign_key "auction_attempts", "users"
  add_foreign_key "auction_bids", "auctions"
  add_foreign_key "auction_bids", "users"
  add_foreign_key "prize_claims", "users"
  add_foreign_key "purchases", "users"
  add_foreign_key "statement_answers", "best_guess_attempts"
  add_foreign_key "statement_answers", "statements"
  add_foreign_key "statements", "best_guesses"
end
