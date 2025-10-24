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

ActiveRecord::Schema[8.0].define(version: 2025_10_24_180000) do
  create_table "authors", force: :cascade do |t|
    t.string "name", null: false
    t.text "bio"
    t.string "profile_image"
    t.string "role", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_authors_on_name"
    t.index ["role"], name: "index_authors_on_role"
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.integer "quantity", default: 1
    t.datetime "added_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_cart_items_on_course_id"
    t.index ["user_id", "course_id"], name: "index_cart_items_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_cart_items_on_user_id"
  end

  create_table "content_pipelines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "course_authors", force: :cascade do |t|
    t.integer "course_id", null: false
    t.integer "author_id", null: false
    t.string "role", null: false
    t.integer "order", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_course_authors_on_author_id"
    t.index ["course_id", "author_id", "role"], name: "index_course_authors_unique", unique: true
    t.index ["course_id"], name: "index_course_authors_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.integer "instructor_id", null: false
    t.string "category"
    t.string "level"
    t.integer "duration"
    t.string "thumbnail"
    t.string "status", default: "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "age"
    t.string "video_url"
    t.string "ebook_pages_root"
    t.string "subtitle"
    t.string "series_name"
    t.integer "series_order"
    t.string "tags"
    t.integer "difficulty", default: 3
    t.integer "discount_percentage", default: 0
    t.date "production_date"
    t.integer "reviews_count", default: 0, null: false
    t.index ["instructor_id"], name: "index_courses_on_instructor_id"
    t.index ["series_name", "series_order"], name: "index_courses_on_series_name_and_series_order"
    t.index ["series_name"], name: "index_courses_on_series_name"
    t.index ["status", "age"], name: "index_courses_on_status_and_age"
    t.index ["status", "category"], name: "index_courses_on_status_and_category"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.datetime "enrolled_at"
    t.integer "progress", default: 0
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "generated_images", force: :cascade do |t|
    t.integer "user_id"
    t.integer "course_id"
    t.string "prompt", null: false
    t.string "image_type", null: false
    t.string "style", default: "modern"
    t.string "size", default: "1024x1024"
    t.string "status", default: "pending"
    t.string "image_url"
    t.text "error_message"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.float "generation_time"
    t.integer "retry_count", default: 0
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "image_type"], name: "index_generated_images_on_course_id_and_image_type"
    t.index ["course_id"], name: "index_generated_images_on_course_id"
    t.index ["image_type"], name: "index_generated_images_on_image_type"
    t.index ["status"], name: "index_generated_images_on_status"
    t.index ["user_id", "status"], name: "index_generated_images_on_user_id_and_status"
    t.index ["user_id"], name: "index_generated_images_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.string "order_id"
    t.decimal "amount"
    t.string "status"
    t.string "payment_key"
    t.datetime "approved_at"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "refunded_at"
    t.text "refund_reason"
    t.index ["course_id"], name: "index_orders_on_course_id"
    t.index ["order_id"], name: "index_orders_on_order_id", unique: true
    t.index ["user_id", "status"], name: "index_orders_on_user_id_and_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.integer "rating"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.index ["active"], name: "index_reviews_on_active"
    t.index ["course_id", "created_at"], name: "index_reviews_on_course_id_and_created_at"
    t.index ["course_id"], name: "index_reviews_on_course_id"
    t.index ["user_id", "course_id"], name: "index_reviews_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "role", default: "student"
    t.text "bio"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "cart_items", "courses"
  add_foreign_key "cart_items", "users"
  add_foreign_key "course_authors", "authors"
  add_foreign_key "course_authors", "courses"
  add_foreign_key "courses", "users", column: "instructor_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "generated_images", "courses"
  add_foreign_key "generated_images", "users"
  add_foreign_key "orders", "courses"
  add_foreign_key "orders", "users"
  add_foreign_key "reviews", "courses"
  add_foreign_key "reviews", "users"
end
