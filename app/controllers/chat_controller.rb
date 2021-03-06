class ChatController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper

  def initialize_session
    puts "Session Initialized\n"
  end
  
  def system_msg(ev, msg)
    broadcast_message ev, { 
      user_name: 'system', 
      user_id: -1,
      user_image_url: 'http://google.com/1.jpg',
      language: 'en',
      received: Time.now.to_s(:short), 
      msg_body: msg
    }
  end
  
  def user_msg(ev, msg, user_name, user_id, user_image_url, language, room)
    translations = {}
    translations[language] = msg
    translations['en'] = ApplicationHelper::Client::translate(msg, 'en')

    puts "done doing translation to en"

    puts "room is " + room

    for key in $redis.keys
      user = JSON.parse($redis.get(key))

      if user["room"] == room
        if translations[user["language"]].nil?
          translations[user["language"]] = ApplicationHelper::Client::translate(msg, user["language"])
        end
      end
    end

    puts "done doing all translations"

    for translation in translations
      WebsocketRails[room].trigger ev, {
        user_name:        user_name, 
        user_id:          user_id,
        user_image_url:   user_image_url,
        language:         translation[0],
        received:         Time.now.to_s(:short), 
        msg_body:         ERB::Util.html_escape(translation[1]) 
      }
    end

    puts "done printing translation"
  end
  
  def client_connected
    system_msg :new_message, "client #{client_id} connected"
  end
  
  def new_message
    user_hash = message[:user_id].to_s + message[:room].to_s
    user = JSON.parse($redis.get(user_hash))
    puts message[:msg_body] + " in " + user["language"]
    puts "from "
    puts user

    user_msg :new_message, message[:msg_body].dup, user["user_name"], user["user_id"], user["user_image_url"], user["language"], user["room"]
  
    puts "Done sending message!"
  end
  
  def new_user
    puts message
    puts "user id:" 
    puts message[:user_id]
    puts "room:"
    puts message[:room]
    user_hash = message[:user_id].to_s + message[:room].to_s
    puts user_hash

    puts({ 
      user_name: sanitize(message[:user_name]),
      user_id: message[:user_id],
      user_image_url: message[:user_image_url],
      room: message[:room],
      language: message[:language]
    })

    $redis.set(user_hash, { 
      user_name: sanitize(message[:user_name]),
      user_id: message[:user_id],
      user_image_url: message[:user_image_url],
      room: message[:room],
      language: message[:language]
    }.to_json)

    puts "new user saved in redis;"
  end
  
  def change_username
    connection_store[:user][:user_name] = sanitize(message[:user_name])
    broadcast_user_list
  end
  
  def delete_user
    connection_store[:user] = nil
    system_msg "client #{client_id} disconnected"
    broadcast_user_list
  end
  
  def broadcast_user_list
    users = connection_store.collect_all(:user)
    broadcast_message :user_list, users
  end
  
end
