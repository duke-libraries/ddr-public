# This migration comes from blacklight (originally 20140320000000)
# -*- encoding : utf-8 -*-
class AddPolymorphicTypeToBookmarks < ActiveRecord::Migration
  def up
    if table_exists?(:bookmarks)
      unless column_exists?(:bookmarks, :document_type)
        add_column(:bookmarks, :document_type, :string)
      end
      
      unless index_exists?(:bookmarks, :user_id)
        add_index :bookmarks, :user_id
      end
    end
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
