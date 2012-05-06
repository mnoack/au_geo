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

ActiveRecord::Schema.define(:version => 20120505010720) do

  create_table "countries", :id => false, :force => true do |t|
    t.string "code", :limit => 2
    t.string "name"
  end

  add_index "countries", ["code"], :name => "index_countries_on_code"
  add_index "countries", ["name"], :name => "index_countries_on_name"

  create_table "localities", :id => false, :force => true do |t|
    t.string  "name"
    t.string  "post_code",        :limit => 4
    t.string  "subdivision_code", :limit => 6
    t.float   "longitude"
    t.float   "latitude"
    t.integer "category_id"
  end

  add_index "localities", ["name"], :name => "index_localities_on_name"
  add_index "localities", ["post_code"], :name => "index_localities_on_post_code"
  add_index "localities", ["subdivision_code", "name"], :name => "index_localities_on_subdivision_code_and_name"
  add_index "localities", ["subdivision_code", "post_code"], :name => "index_localities_on_subdivision_code_and_post_code"

  create_table "subdivisions", :id => false, :force => true do |t|
    t.string "code",         :limit => 6
    t.string "name"
    t.string "country_code", :limit => 2
  end

  add_index "subdivisions", ["country_code", "code"], :name => "index_subdivisions_on_country_code_and_code"
  add_index "subdivisions", ["name"], :name => "index_subdivisions_on_name"

end
