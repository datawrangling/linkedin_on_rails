begin
   APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]
rescue
   # else look in environment for keys, fo use in Heroku w/ Github, etc.
   # see http://docs.heroku.com/config-vars
   puts "No yml config file, attempting to fetch APP_CONFIG keys from local environment"
   APP_CONFIG = {}
   APP_CONFIG['api_key'] = ENV['LINKEDIN_API_KEY']
   APP_CONFIG['secret_key'] = ENV['LINKEDIN_SECRET_KEY']
   if APP_CONFIG['api_key']
     puts "Keys found..."
   end   
   # for heroku
   # $ cd linkedin_on_rails
   # $ heroku config:add LINKEDIN_API_KEY=12345 LINKEDIN_SECRET_KEY=ABC123
   
   # for local development, just add them to your .bashrc or profile
   #
   # export LINKEDIN_API_KEY=12345   
   # export LINKEDIN_SECRET_KEY=ABC123

end

