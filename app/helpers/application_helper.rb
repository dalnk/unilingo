module ApplicationHelper
  require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
#require 'net/http'
require 'open-uri'
#require 'uri'
require 'json'

# api key or something: AIzaSyARRZoVs8THRTDbNM-t6uCYRsU0XofY_mQ

class Client

    def self.initialize()
        @source_url = "https://www.googleapis.com/language/translate/v2?q=QUESTION&target=TARGET&format=text&key=AIzaSyARRZoVs8THRTDbNM-t6uCYRsU0XofY_mQ"
    end

=begin
    def send_get()
        url = URI.parse(source_url);
        req = Net::HTTP::Get.new(url.path)
        res = Net::HTTP.start(url.host, url.port) {
            |http|
            http.request(req)
        }
        puts res.body
    end
=end
    def self.send_get()
        return "hello world"
    end

    #in_text is the string to translate
    #lang is the language to translate to
    def self.translate(in_text, lang)
        @source_url = "https://www.googleapis.com/language/translate/v2?q=QUESTION&target=TARGET&format=text&key=AIzaSyARRZoVs8THRTDbNM-t6uCYRsU0XofY_mQ"

        #in_text = in_text.gsub(" ", "%20")
        #puts @source_url
        url = "#{@source_url}".sub("QUESTION", in_text).sub("TARGET", lang)
        url = URI.escape(url)
        #puts "\nhi\n"
        #puts url
        #puts "\nhi\n"
        puts "___error___"
        puts open(url)
        puts "___error___"
        res = JSON.load(open(url))
        return res["data"]["translations"].first["translatedText"]
    end
=begin
    puts "___before"
    translate("the building is on fire", "ru")
    puts "___after"
=end

    def send_put()
    end

    def run_request()
    end
end

=begin
if __FILE__ == $0
    puts "\nHELLO\n"
    client = Client.new
    puts client.translate("hello how are you", "zh-CN")
    #puts client.translate("здание в огне", "en")
    #Client.translate("the building is on fire", "ru")
end
=end

=begin
# Initialize the client.
client = Google::APIClient.new(
  :application_name => 'Example Ruby application',
  :application_version => '1.0.0'
)

# Initialize Google+ API. Note this will make a request to the
# discovery service every time, so be sure to use serialization
# in your production code. Check the samples for more details.
plus = client.discovered_api('plus')

# Load client secrets from your client_secrets.json.
client_secrets = Google::APIClient::ClientSecrets.load

# Run installed application flow. Check the samples for a more
# complete example that saves the credentials between runs.
flow = Google::APIClient::InstalledAppFlow.new(
  :client_id => client_secrets.client_id,
  :client_secret => client_secrets.client_secret,
  :scope => ['https://www.googleapis.com/auth/plus.me']
)
client.authorization = flow.authorize

# Make an API call.
result = client.execute(
  :api_method => plus.activities.list,
  :parameters => {'collection' => 'public', 'userId' => 'me'}
)

puts result.data
=end

end
