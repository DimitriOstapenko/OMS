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

ActiveRecord::Schema.define(version: 2019_12_15_212305) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "client_mails", force: :cascade do |t|
    t.datetime "ts_sent"
    t.integer "client_type"
    t.integer "category"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "target_emails"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.integer "cltype", default: 0
    t.string "code"
    t.string "country"
    t.string "state_prov"
    t.string "address"
    t.string "zip_postal"
    t.string "web"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_fname"
    t.string "contact_lname"
    t.string "vat"
    t.string "contact_phone"
    t.string "contact_email"
    t.integer "price_type", default: 0
  end

  create_table "managers", force: :cascade do |t|
    t.string "lname"
    t.string "fname"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "client_id"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "po_number"
    t.string "web_id"
    t.integer "status", default: 0
    t.string "inv_number"
    t.index ["client_id"], name: "index_orders_on_client_id"
  end

  create_table "placements", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
    t.decimal "price"
    t.index ["order_id"], name: "index_placements_on_order_id"
    t.index ["product_id"], name: "index_placements_on_product_id"
  end

  create_table "prices", force: :cascade do |t|
    t.integer "scale", default: 18
    t.decimal "price_eu"
    t.decimal "price_eu2"
    t.decimal "price_usd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category"
  end

  create_table "products", force: :cascade do |t|
    t.string "description"
    t.integer "brand"
    t.integer "category"
    t.string "notes"
    t.integer "colour"
    t.integer "scale"
    t.date "release_date"
    t.decimal "price_eu"
    t.decimal "price_usd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ctns"
    t.string "ref_code"
    t.date "added_date"
    t.integer "supplier"
    t.integer "manager"
    t.integer "progress"
    t.integer "quantity", default: 0
    t.decimal "price_eu2", default: "0.0"
    t.index ["ref_code"], name: "index_products_on_ref_code"
  end

  create_table "reports", force: :cascade do |t|
    t.string "name"
    t.integer "client_id"
    t.string "rtype"
    t.integer "timeframe"
    t.datetime "sdate"
    t.datetime "edate"
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "detail"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "company"
    t.string "lname"
    t.string "fname"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.string "name"
    t.bigint "client_id"
    t.index ["client_id"], name: "index_users_on_client_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "orders", "clients"
  add_foreign_key "placements", "orders"
  add_foreign_key "placements", "products"
  add_foreign_key "users", "clients"
end
