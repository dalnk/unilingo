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
  
  def user_msg(ev, msg, user_name, user_id, user_image_url, language)
    WebsocketRails[connection_store[:room]].trigger ev, {
      user_name:        user_name, 
      user_id:          user_id,
      user_image_url:   user_image_url,
      language:         language,
      received:         Time.now.to_s(:short), 
      msg_body:         ERB::Util.html_escape(msg) 
    }
  end
  
  def client_connected
    system_msg :new_message, "client #{client_id} connected"
  end
  
  def new_message
    user_hash = message[:user_id].to_s + message[:room].to_s
    user = JSON.parse($redis.get(user_hash))

    puts "hi dennis"
    puts user
    puts "bye dennis"

    user_msg :new_message, message[:msg_body].dup, user["user_name"], user["user_id"], user["user_image_url"], user["language"]
  end
  
  def new_user
    print "fuck you dennis"
    user_hash = message[:user_id].to_s + message[:room].to_s
    print user_hash

    print({ 
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

    puts "new user saved in redis; dennis sucks"
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
