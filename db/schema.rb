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

ActiveRecord::Schema[7.0].define(version: 2025_11_11_201459) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "classlists", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "semester_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["semester_id"], name: "index_classlists_on_semester_id"
    t.index ["student_id"], name: "index_classlists_on_student_id"
  end

  create_table "repos", force: :cascade do |t|
    t.string "name"
    t.integer "commit_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "repositories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "owner"
    t.text "repo_name"
    t.text "team"
    t.bigint "user_id", null: false
    t.bigint "semester_id"
    t.bigint "team_id"
    t.integer "commit_count"
    t.index ["semester_id"], name: "index_repositories_on_semester_id"
    t.index ["team_id"], name: "index_repositories_on_team_id"
    t.index ["user_id"], name: "index_repositories_on_user_id"
  end

  create_table "semesters", force: :cascade do |t|
    t.integer "year"
    t.string "semester"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.bigint "user_id"
    t.index ["semester", "year"], name: "index_semesters_on_semester_and_year", unique: true
    t.index ["user_id"], name: "index_semesters_on_user_id"
  end

  create_table "sprints", force: :cascade do |t|
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name"
    t.bigint "semester_id"
    t.index ["semester_id"], name: "index_sprints_on_semester_id"
  end

  create_table "student_teams", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_student_teams_on_student_id"
    t.index ["team_id"], name: "index_student_teams_on_team_id"
  end

  create_table "students", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.string "email"
    t.string "github_username"
    t.integer "team_id"
    t.string "team_name"
    t.string "project_board_url"
    t.string "timesheet_url"
    t.string "client_notes_url"
    t.bigint "semester_id"
    t.index ["semester_id"], name: "index_students_on_semester_id"
    t.index ["team_id", "github_username"], name: "index_students_on_team_id_and_github_username", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "semester_id", null: false
    t.string "github_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "repo_url"
    t.string "timesheet_url"
    t.string "project_board_url"
    t.string "client_notes_url"
    t.index ["semester_id"], name: "index_teams_on_semester_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_token"
    t.boolean "admin", default: false
    t.integer "role", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "classlists", "semesters"
  add_foreign_key "classlists", "students"
  add_foreign_key "repositories", "semesters"
  add_foreign_key "repositories", "teams"
  add_foreign_key "repositories", "users"
  add_foreign_key "semesters", "users"
  add_foreign_key "sprints", "semesters"
  add_foreign_key "student_teams", "students"
  add_foreign_key "student_teams", "teams"
  add_foreign_key "students", "semesters"
  add_foreign_key "teams", "semesters"
end
