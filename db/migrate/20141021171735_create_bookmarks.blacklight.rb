# This migration comes from blacklight (originally 20140202020202)
# -*- encoding : utf-8 -*-
class CreateBookmarks < ActiveRecord::Migration
  def self.up
    unless table_exists?(:bookmarks)
      create_table :bookmarks do |t|
        t.integer :user_id, :null=>false
        t.string :user_type
        t.string :document_id
        t.string :title
        t.timestamps
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
  
end
