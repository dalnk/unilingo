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
  
  def user_msg(ev, msg)
    print "\n\n\n"
    print "dennis sucks\n"
    print "ROOM:\n"
    print connection_store[:room]
    print "USER:\n"
    print connection_store[:user]
    print "\n\n\n"


    WebsocketRails[connection_store[:room]].trigger ev, {
      user_name:        connection_store[:user][:user_name], 
      user_id:          connection_store[:user][:user_id],
      user_image_url:   connection_store[:user][:user_image_url],
      language:         connection_store[:user][:language],
      received:         Time.now.to_s(:short), 
      msg_body:         ERB::Util.html_escape(msg) 
    }
  end
  
  def client_connected
    system_msg :new_message, "client #{client_id} connected"
  end
  
  def new_message
    user_msg :new_message, message[:msg_body].dup
  end
  
  def new_user
    connection_store[:user] = { 
      user_name: sanitize(message[:user_name]),
      user_id: message[:user_id],
      user_image_url: message[:user_image_url],
      room: message[:room],
      language: message[:language]
    }
    connection_store[:room] = message[:room]
    connection_store[:room] = "fuck dennis"
    broadcast_user_list
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
