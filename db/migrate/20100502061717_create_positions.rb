class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.string :linkedin_position_id
      t.string :title
      t.text :summary
      t.string :is_current
      t.date :start_date
      t.date :end_date
      t.boolean :is_current
      t.string :company
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :positions
  end
end
