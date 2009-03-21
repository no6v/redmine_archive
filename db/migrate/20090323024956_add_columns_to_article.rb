class AddColumnsToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :user_id, :integer
    add_column :articles, :updated_on, :datetime
  end

  def self.down
    remove_column :articles, :user_id
    remove_column :articles, :updated_on
  end
end
