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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120704235608) do

  create_table "clients", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
    t.string   "company_name"
    t.string   "company_url"
    t.text     "company_description"
    t.string   "full_name"
    t.integer  "user_id"
    t.string   "twitter_username"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "designer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["designer_id"], :name => "index_comments_on_designer_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "designer_posts", :force => true do |t|
    t.text     "comment"
    t.string   "duration"
    t.string   "availability_date"
    t.string   "location"
    t.string   "relocate"
    t.string   "minimum_budget"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "job_type"
    t.string   "coding"
    t.integer  "designer_id"
    t.string   "weekly_hours"
    t.integer  "status_id"
  end

  create_table "designer_replies", :force => true do |t|
    t.integer  "job_offer_id"
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "collapsed"
    t.boolean  "picked"
  end

  create_table "designers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "portfolio_url"
    t.string   "twitter_username"
    t.string   "location"
    t.string   "short_bio"
    t.string   "skype_username"
    t.string   "dribble_username"
    t.string   "linkedin_url"
    t.string   "behance_username"
    t.text     "long_bio"
    t.string   "full_name"
    t.integer  "user_id"
    t.boolean  "is_public"
    t.integer  "status_id",          :default => 1
    t.integer  "profile_type_id",    :default => 1
    t.string   "zerply_username"
    t.string   "featured_shot"
    t.integer  "minimum_budget"
    t.string   "coordinates"
    t.string   "featured_shot_url"
    t.string   "featured_shot_page"
    t.integer  "rate"
  end

  create_table "designers_skills", :id => false, :force => true do |t|
    t.integer "designer_id"
    t.integer "skill_id"
  end

  create_table "evaluations", :force => true do |t|
    t.text     "comment"
    t.integer  "job_offer_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "evaluation"
    t.integer  "designer_id"
  end

  create_table "job_offers", :force => true do |t|
    t.datetime "date_sent_out"
    t.string   "title"
    t.text     "full_description"
    t.integer  "compensation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
    t.integer  "work_type_id"
    t.integer  "location_type_id"
    t.integer  "status_id",        :default => 1
    t.boolean  "is_open",          :default => true
    t.string   "discount"
    t.integer  "discount_amount"
    t.integer  "comp_high"
    t.integer  "coding"
    t.string   "budget_range"
    t.integer  "budget_type"
    t.datetime "approved_at"
    t.datetime "paid_at"
    t.datetime "archived_at"
    t.datetime "refunded_at"
  end

  create_table "job_offers_skills", :id => false, :force => true do |t|
    t.integer "job_offer_id"
    t.integer "skill_id"
  end

  create_table "location_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "comment"
    t.integer  "from_user_id"
    t.integer  "to_user_id"
  end

  create_table "orders", :force => true do |t|
    t.string   "express_token"
    t.string   "express_payer_id"
    t.integer  "job_offer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
    t.string   "email"
    t.text     "details"
    t.integer  "total"
  end

  create_table "profile_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "role_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "skills", :force => true do |t|
    t.string "name"
  end

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                                :null => false
    t.string   "encrypted_password",     :limit => 128,                :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
    t.string   "referrer"
    t.integer  "referrer_designer"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "work_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
