# This migration comes from blacklight (originally 20140202020201)
# -*- encoding : utf-8 -*-
class CreateSearches < ActiveRecord::Migration
  def self.up
    unless table_exists?(:searches)
      create_table :searches do |t|
        t.text  :query_params
        t.integer :user_id
        t.string :user_type

        t.timestamps
      end

      add_index :searches, :user_id
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
