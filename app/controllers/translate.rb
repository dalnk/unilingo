require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
#require 'net/http'
require 'open-uri'
#require 'uri'
require 'json'

class Client

    def initialize()
        @source_url = "https://www.googleapis.com/language/translate/v2?q=QUESTION&target=TARGET&format=text&key=AIzaSyARRZoVs8THRTDbNM-t6uCYRsU0XofY_mQ"
    end

    def send_get()
        return "hello world"
    end

    #in_text is the string to translate
    #lang is the language to translate to
    def translate(in_text, lang)
        # url = "#{@source_url}".sub("QUESTION", in_text).sub("TARGET", lang)
        # url = URI.escape(url)
        # res = JSON.load(open(url))
        # return res["data"]["translations"].first["translatedText"]
        return in_text
    end

    def send_put()
    end

    def run_request()
    end
end