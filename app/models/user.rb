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
  
  def member_urls
    @foo = JSON.parse(self.member_url_resources)
    @foo['member_url']
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
  
  
  
private

  def populate_oauth_user
    unless oauth_token.blank?
      # 1) Fetch profile info (name, headline, industry, profile pic, public url, summary, specialties, web urls)
      # @response = UserSession.oauth_consumer.request(:get, 'http://api.linkedin.com/v1/people/~',
      @response = UserSession.oauth_consumer.request(:get, 
      'http://api.linkedin.com/v1/people/~:(id,first-name,last-name,headline,industry,summary,specialties,interests,picture-url,public-profile-url,site-standard-profile-request,location,member-url-resources,honors,associations)',
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
        self.member_url_resources = user_info['member_url_resources'].to_json                     
      end
      
    end  
  end  
      
  def populate_child_models 
    unless oauth_token.blank?     
      # 2) Save past position info for user (companies, job titles, durations, descriptions)
      @response = UserSession.oauth_consumer.request(:get, 
      'http://api.linkedin.com/v1/people/~:(id,positions,educations,connections)',
      access_token, { :scheme => :query_string })
      case @response
      when Net::HTTPSuccess
        user_info = Crack::XML.parse(@response.body)['person']        
        user_info['positions']['position'].each do |position|
          # create position record
          # *** start and end dates may be missing ***         
          # <position>
          #   <id>88857582</id>
          #   <title>Sr. Data Scientist</title>
          #   <summary>Applying statistical approaches at scale at LinkedIn.  Mining information from LinkedIn profile content, the social graph, and external data sources to build data driven products and surface actionable insights for members.  My current tool set includes things like Hadoop, Pig, Hive, Voldemort, Mechanical Turk, Java, Python, NLTK, along with various machine learning and numerical libraries.  Building prototype web applications with Rails and Django.</summary>
          #   <start-date>
          #     <year>2009</year>
          #     <month>9</month>
          #   </start-date>
          #   <is-current>true</is-current>
          #   <company>
          #     <name>LinkedIn</name>
          #   </company>
          # </position> 
          position_params = {}
          position_params[:linkedin_position_id] = position['id']
          position_params[:title] = position['title']
          position_params[:summary] = position['summary']
          position_params[:is_current] = position['is-current']
          position_params[:company] = position['company']['name']   
          position_params[:start_date] = extract_date(position['start_date'])
          position_params[:end_date] = extract_date(position['end_date']) 
                     
          self.positions.create(position_params)         
        end  

        # # 3) Save education info for user (schools, degrees, field of study, dates, etc)        
        user_info['educations']['education'].each do |education|
          # create education record
          education_params = {}
          education_params[:linkedin_education_id] = education['id']
          education_params[:school_name] = education['school_name']
          education_params[:degree] = education['degree'] 
          education_params[:field_of_study] = education['field_of_study']
          education_params[:notes] = education['notes'] 
          education_params[:start_date] = extract_date(education['start_date'])
          education_params[:end_date] = extract_date(education['end_date'])
          
          self.educations.create(education_params)     
        end        

        # 4) Save connections info - names, industries, headlines, profile pics,
        # Use Connections model
        user_info['connections']['person'].each do |person|
          #puts person['first_name'] + ' ' + person['last_name']
          connection_params = {}
          connection_params[:logged_in_url] = person['site_standard_profile_request']['url']
          connection_params[:member_id] = connection_params[:logged_in_url].split('&')[1].split('=')[1].to_i
          connection_params[:first_name] = person['first_name']
          connection_params[:last_name] = person['last_name']
          connection_params[:headline] = person['headline']
          connection_params[:location] = person['location']['name']
          connection_params[:location] = person['location']['country']['code']  
          connection_params[:industry] = person['industry']                      
          connection_params[:picture_url] = person['picture_url']                    
          
          self.connections.create(connection_params)
          
        end  
      end    
      
    end  
  end        
  
end
