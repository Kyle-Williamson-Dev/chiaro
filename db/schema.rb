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

ActiveRecord::Schema[8.1].define(version: 2026_09_30_032225) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "model_id", null: false
    t.bigint "photographer_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "requester_id"
    t.index ["model_id"], name: "index_bookings_on_model_id"
    t.index ["photographer_id"], name: "index_bookings_on_photographer_id"
    t.index ["requester_id"], name: "index_bookings_on_requester_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "author_id", null: false
    t.integer "rating"
    t.text "comment"
    t.string "credited_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_feedbacks_on_author_id"
    t.index ["booking_id", "author_id"], name: "index_feedbacks_on_booking_id_and_author_id", unique: true
    t.index ["booking_id"], name: "index_feedbacks_on_booking_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "display_name", null: false
    t.text "bio"
    t.string "city"
    t.string "instagram"
    t.text "boundaries"
    t.string "shoot_types", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "safety_reports", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "reporter_id", null: false
    t.text "body", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id", "reporter_id"], name: "index_safety_reports_on_booking_id_and_reporter_id", unique: true
    t.index ["booking_id"], name: "index_safety_reports_on_booking_id"
    t.index ["reporter_id"], name: "index_safety_reports_on_reporter_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "role", default: 0, null: false
    t.string "city"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "users", column: "model_id"
  add_foreign_key "bookings", "users", column: "photographer_id"
  add_foreign_key "bookings", "users", column: "requester_id"
  add_foreign_key "feedbacks", "bookings"
  add_foreign_key "feedbacks", "users", column: "author_id"
  add_foreign_key "profiles", "users"
  add_foreign_key "safety_reports", "bookings"
  add_foreign_key "safety_reports", "users", column: "reporter_id"
end
