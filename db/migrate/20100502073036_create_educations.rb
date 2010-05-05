class CreateEducations < ActiveRecord::Migration
  def self.up
    create_table :educations do |t|
      t.string :linkedin_education_id
      t.string :school_name
      t.string :degree
      t.string :field_of_study
      t.date :start_date
      t.date :end_date
      t.text :notes
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :educations
  end
end
