class AddLinkedinInformationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :member_id, :string
    add_column :users, :picture_url, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string  
    add_column :users, :headline, :string 
    add_column :users, :industry, :string  
    add_column :users, :summary, :text  
    add_column :users, :specialties, :text
    add_column :users, :interests, :text
    add_column :users, :logged_in_url, :string
    add_column :users, :public_profile_url, :string
    add_column :users, :location, :string
    add_column :users, :country, :string    
    add_column :users, :member_id_token, :string  
    add_column :users, :honors, :string  
    add_column :users, :associations, :string 
    add_column :users, :member_url_resources, :text              
    
  end

  def self.down
    remove_column :users, :honors
    remove_column :users, :associations
    remove_column :users, :member_url_resources
    remove_column :users, :member_id_token
    remove_column :users, :country
    remove_column :users, :location
    remove_column :users, :public_profile_url
    remove_column :users, :logged_in_url    
    remove_column :users, :industry
    remove_column :users, :summary
    remove_column :users, :specialties  
    remove_column :users, :interests          
    remove_column :users, :headline
    remove_column :users, :last_name
    remove_column :users, :first_name
    remove_column :users, :picture_url    
    remove_column :users, :member_id
  end
end
