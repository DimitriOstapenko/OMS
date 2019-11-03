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

ActiveRecord::Schema.define(version: 2019_11_03_105259) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
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
    t.index ["client_id"], name: "index_orders_on_client_id"
  end

  create_table "placements", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
    t.index ["order_id"], name: "index_placements_on_order_id"
    t.index ["product_id"], name: "index_placements_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "description"
    t.integer "brand"
    t.string "category"
    t.string "notes"
    t.string "colour"
    t.integer "scale"
    t.date "release_date"
    t.decimal "price_eu"
    t.decimal "price_usd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ctns"
    t.string "ref_code"
    t.decimal "price_eu2"
    t.date "added_date"
    t.integer "supplier"
    t.string "manager"
    t.integer "progress"
    t.integer "quantity", default: 0
    t.index ["ref_code"], name: "index_products_on_ref_code"
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
    t.boolean "active", default: true
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
