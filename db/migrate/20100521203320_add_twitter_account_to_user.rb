class AddTwitterAccountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_accounts, :string
  end

  def self.down
    remove_column :users, :twitter_accounts
  end
end
