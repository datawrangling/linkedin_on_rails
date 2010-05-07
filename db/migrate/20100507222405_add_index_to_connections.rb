class AddIndexToConnections < ActiveRecord::Migration
  def self.up
    add_index "connections", ["user_id"], :name => "connections_user_index"
  end

  def self.down
    remove_index "connections", "connections_user_index"
  end
end
