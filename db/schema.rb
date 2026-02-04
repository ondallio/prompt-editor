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

ActiveRecord::Schema[7.2].define(version: 2026_02_04_004756) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_providers", force: :cascade do |t|
    t.string "name"
    t.string "provider_type"
    t.string "api_key"
    t.string "ai_model"
    t.string "endpoint_url"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "color"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "executions", force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.bigint "ai_provider_id", null: false
    t.jsonb "input_variables", default: {}
    t.text "rendered_content"
    t.text "response_text"
    t.integer "token_count"
    t.string "status", default: "pending"
    t.integer "duration_ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_provider_id"], name: "index_executions_on_ai_provider_id"
    t.index ["prompt_id"], name: "index_executions_on_prompt_id"
  end

  create_table "prompt_variables", force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.string "name"
    t.string "default_value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_id"], name: "index_prompt_variables_on_prompt_id"
  end

  create_table "prompt_versions", force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.integer "version_number"
    t.text "content"
    t.text "system_prompt"
    t.string "change_note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_id"], name: "index_prompt_versions_on_prompt_id"
  end

  create_table "prompts", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "category_id"
    t.text "system_prompt"
    t.integer "current_version", default: 1
    t.boolean "favorite", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_prompts_on_category_id"
  end

  add_foreign_key "executions", "ai_providers"
  add_foreign_key "executions", "prompts"
  add_foreign_key "prompt_variables", "prompts"
  add_foreign_key "prompt_versions", "prompts"
  add_foreign_key "prompts", "categories"
end
