class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.column :list, :string, :null => false, :default => "", :limit => 64
      t.column :count, :integer, :null => false, :default => 0
      t.column :path, :string, :null => false, :default => "", :limit => 255
      t.column :hidden, :boolean, :null => false, :default => false
    end
  end

  def self.down
    drop_table :articles
  end
end
