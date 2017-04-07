require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection("adapter": "sqlite3", "database": "hoge.db")

ActiveRecord::Migration.create_table(:slugs, id: false, primary_key: 'slug_id' ) do |t|
  t.string :slug_id, unique: true, null: false 
  t.timestamps
end

=begin
create table sessions(
session_id varchar(50) unique primary key,
created_at timestamp default (datetime('now', 'localtime'))
)
=end
