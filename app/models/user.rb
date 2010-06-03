class User < ActiveRecord::Base
  require 'crack'
  acts_as_authentic
  
  before_create :populate_oauth_user
  after_create :populate_child_models
  
  has_many :positions
  has_many :educations 
  has_many :connections
  
  # TODO - add methods to update profile info on each login or update request
  # TODO - pull status updates, specialties, and current position for connection 
  
  def picture
    if self.picture_url != nil
      url = self.picture_url
    else  
      url= "icon_no_photo_80x80.png"
    end  
  end  
  
  def twitter_urls
    # '{\"twitter_account\":{\"provider_account_name\":[\"peteskomoroch\"],\"provider_account_id\":\"14344469\"},\"total\":\"1\"}'
    urls = nil
    if self.twitter_accounts != 'null'
      @foo = JSON.parse(self.twitter_accounts)
      urls = @foo['twitter_account']
    end
    return urls  
  end  
  
  
  def member_urls
    urls = nil
    if self.member_url_resources != 'null'
      @foo = JSON.parse(self.member_url_resources)
      urls = @foo['member_url']
    end
    return urls  
  end  
  
  def extract_date(date_xml)
    dateval = nil
    if date_xml
      year = date_xml['year']
      month = date_xml['month']
      if year && month
        dateval = Date.new(year.to_i, month.to_i)
      elsif year
        dateval = Date.new(year.to_i)  
      end 
    end  
    dateval 
  end
  
  
  def extract_position(position)
    # extract data
    # create position record
    # *** start and end dates may be missing ***           
    position_params = {}
    position_params.default = nil
    position_params[:linkedin_position_id] = position['id']
    position_params[:title] = position['title']
    if position['summary']:
      position_params[:summary] = position['summary']
    end  
    position_params[:is_current] = position['is-current']
    if position['company']:
      position_params[:company] = position['company']['name']   
    end  
    position_params[:start_date] = extract_date(position['start_date'])
    position_params[:end_date] = extract_date(position['end_date'])    
    return position_params
  end
  
  def extract_education(education)
    education_params = {}
    education_params.default = nil          
    education_params[:linkedin_education_id] = education['id']
    education_params[:school_name] = education['school_name']
    education_params[:degree] = education['degree'] 
    education_params[:field_of_study] = education['field_of_study']
    education_params[:notes] = education['notes'] 
    education_params[:start_date] = extract_date(education['start_date'])
    education_params[:end_date] = extract_date(education['end_date'])
    return education_params
  end
  
  def extract_connection(person)
    # extract data
    connection_params = {}
    connection_params.default = nil
    connection_params[:logged_in_url] = person['site_standard_profile_request']['url']
    connection_params[:member_id] = connection_params[:logged_in_url].split('&')[1].split('=')[1].to_i
    connection_params[:first_name] = person['first_name']
    connection_params[:last_name] = person['last_name']
    connection_params[:headline] = person['headline']
    connection_params[:location] = person['location']['name']
    connection_params[:country] = person['location']['country']['code']  
    connection_params[:industry] = person['industry']                      
    connection_params[:picture_url] = person['picture_url']
    return connection_params
  end
  
  def extract_member_urls(member_urls)
    member_url_resources = nil
    if member_urls['total'].to_i > 1    
      member_url_resources = member_urls
    elsif member_urls['total'].to_i == 1
      member_url_resources = member_urls
      member_url_resources["member_url"] = [member_urls["member_url"]]
    end
    return member_url_resources.to_json
  end  
  
  def extract_twitter_ids(twitter_accounts)
    #twitter_account:
    # provider_account_name: peteskomoroch
    # provider_account_id: 14344469
    # total: 1
    twitter_account_resources = nil
    if twitter_accounts['total'].to_i > 1    
      twitter_account_resources = twitter_accounts
    elsif twitter_accounts['total'].to_i == 1
      twitter_account_resources = twitter_accounts
      twitter_account_resources["twitter_account"] = [twitter_account_resources["twitter_account"]]
    end
    return twitter_account_resources.to_json
  end  
  
    
private

  def populate_oauth_user
    unless oauth_token.blank?
      # 1) Fetch profile info (name, headline, industry, profile pic, public url, summary, specialties, web urls)
      # @response = UserSession.oauth_consumer.request(:get, 'http://api.linkedin.com/v1/people/~',
      @response = UserSession.oauth_consumer.request(:get, 
      'http://api.linkedin.com/v1/people/~:(id,first-name,last-name,headline,industry,summary,specialties,interests,picture-url,public-profile-url,site-standard-profile-request,location,twitter-accounts,member-url-resources,honors,associations)',
      access_token, { :scheme => :query_string })
      case @response
      when Net::HTTPSuccess
        #user_info = Profile.from_xml(get(path))
        user_info = Crack::XML.parse(@response.body)['person']
        self.member_id_token = user_info['id']
        self.logged_in_url = user_info['site_standard_profile_request']['url']
        self.member_id = self.logged_in_url.split('&')[1].split('=')[1]       
        self.first_name = user_info['first_name']
        self.last_name = user_info['last_name']
        self.headline = user_info['headline']      
        self.industry = user_info['industry'] 
        self.summary = user_info['summary'] 
        self.specialties = user_info['specialties'] 
        self.interests = user_info['interests']         
        self.picture_url = user_info['picture_url'] 
        self.public_profile_url = user_info['public_profile_url'] 
        self.location = user_info['location']['name'] 
        self.country = user_info['location']['country']['code']
        self.honors = user_info['honors']
        self.associations = user_info['associations']
        self.twitter_accounts = extract_twitter_ids(user_info['twitter_accounts'])           
        self.member_url_resources = extract_member_urls(user_info['member_url_resources'])                 
      end      
    end  
  end  
      
  def populate_child_models 
    unless oauth_token.blank?     
      @response = UserSession.oauth_consumer.request(:get, 
      'http://api.linkedin.com/v1/people/~:(id,positions,educations,connections)',
      access_token, { :scheme => :query_string })
      case @response
      when Net::HTTPSuccess
        user_info = Crack::XML.parse(@response.body)['person'] 
        
        # 2) Save past position info for user (companies, job titles, durations, descriptions) 
        if user_info['positions']['total'].to_i > 1    
          user_info['positions']['position'].each do |position|
            position_params = extract_position(position)
            self.positions.create(position_params)
          end
        else
          position_params = extract_position(user_info['positions']['position'])
          self.positions.create(position_params)
        end 

        # 3) Save education info for user (schools, degrees, field of study, dates, etc)    
        if user_info['educations']['total'].to_i > 1    
          user_info['educations']['education'].each do |education|
            education_params = extract_education(education)
            self.educations.create(education_params)
          end
        else
          education_params = extract_education(user_info['educations']['education'])
          self.educations.create(education_params)
        end    

        # 4) Save connections info - names, industries, headlines, profile pics,
        # Use Connections model
        if user_info['connections']['total'].to_i > 1    
          user_info['connections']['person'].each do |person|
            connection_params = extract_connection(person)
            self.connections.create(connection_params)
          end
        else
          connection_params = extract_connection(user_info['connections']['person'])
          self.connections.create(connection_params)
        end        
           
      end    
      
    end  
  end        
  
end
