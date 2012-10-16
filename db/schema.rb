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

ActiveRecord::Schema.define(:version => 20121016055635) do

  create_table "dashboards", :force => true do |t|
    t.string "name"
  end

  create_table "metrics", :force => true do |t|
    t.string  "name",                               :null => false
    t.string  "description"
    t.string  "units"
    t.string  "graph_url"
    t.string  "service_identifier", :limit => 1024
    t.integer "service_id"
    t.integer "section_id"
    t.integer "position"
  end

  create_table "sections", :force => true do |t|
    t.string  "name"
    t.integer "dashboard_id"
    t.integer "column",       :default => 1
    t.integer "position"
  end

  create_table "services", :force => true do |t|
    t.string "service_type"
    t.string "settings",     :limit => 4096
  end

end
