# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  class ActiveRecord::Base
    # given a hash of attributes including the ID, look up the record by ID. 
    # If it does not exist, it is created with the rest of the options. 
    # If it exists, it is updated with the given options. 
    #
    # Raises an exception if the record is invalid to ensure seed data is loaded correctly.
    # 
    # Returns the record.
    def self.create_or_update(options = {})
      id = options.delete(:id)
      record = find_by_id(id) || new
      record.id = id
      record.attributes = options
      record.save!

      record
    end
  end
  
end
