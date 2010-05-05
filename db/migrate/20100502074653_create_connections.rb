class CreateConnections < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.integer :member_id      
      t.string :first_name
      t.string :last_name
      t.string :headline
      t.string :location
      t.string :country
      t.string :industry
      t.string :logged_in_url
      t.string :picture_url
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :connections
  end
end
