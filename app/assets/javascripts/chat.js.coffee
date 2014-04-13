# jQuery ->
#   window.chatController = new Chat.Controller($('#chat').data('uri'), true);

window.Chat = {}

class Chat.User
  constructor: (@user_name, @user_id, @user_image_url, @room, @language) ->
  serialize: => { 
    user_name: @user_name,
    user_id: @user_id,
    user_image_url: @user_image_url,
    room: @room,
    language: @language
  }

class Chat.Controller
  template: (message) ->
    html =
      """
      <div class="message-#{message.user_type} message-block" >
        <label class="label label-info">
          [#{message.received}] #{message.user_name}
        </label>
        <div class="circle_crop user_icon">
          <img class="user_icon_img" src="#{message.user_image_url}">
        </div>
        <div class="message-bubble">
          #{message.msg_body}
        </div>
      </div>
      """
    $(html)

  userListTemplate: (userList) ->
    userHtml = ""
    for user in userList
      userHtml = userHtml + "<li>#{user.user_name}</li>"
    $(userHtml)

  constructor: (url,useWebSockets) ->
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebSockets)


  bindEvents: =>
    @channel.bind 'new_message', @newMessage
    @channel.bind 'user_list', @updateUserList
    $('input#user_name').on 'keyup', @updateUserInfo
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13
    console.log("Done binding events.");

  newMessage: (message) =>
    console.log("Message received: " + message['msg_body'])

    # return if message['language'] != @user.language

    message['user_type'] = "them"
    message['user_type'] = "me" if message['user_id'] == @user.user_id
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 15
    @appendMessage message

  sendMessage: (event) =>
    event.preventDefault()
    console.log('sent message')
    message = $('#message').val()
    @dispatcher.trigger 'new_message', {user_name: @user.user_name, msg_body: message, user_id: @user.user_id, room: @user.room }
    $('#message').val('')

  updateUserList: (userList) =>
    console.log("udpatedUserList called")
    console.log(userList)
    $('#user-list').html @userListTemplate(userList)

  updateUserInfo: (event) =>
    @user.user_name = $('input#user_name').val()
    $('#username').html @user.user_name
    @dispatcher.trigger 'change_username', @user.serialize()

  appendMessage: (message) =>
    messageTemplate = @template(message)
    $('#chat').append messageTemplate
    messageTemplate.slideDown 140

  joinRoom: (room, userName, userId, userImageUrl, language) =>
    console.log("Subscribing to channel " + room)
    @channel = @dispatcher.subscribe(room)

    console.log("Adding new user alert for " + userName + ", " + userId + ", " + userImageUrl + ", " + language)
    @user = new Chat.User(userName, userId, userImageUrl, room, language)

    console.log(@user.serialize())

    @dispatcher.trigger 'new_user', @user.serialize()

    console.log("Binding events...")
    @bindEvents()

    console.log("Done joining room " + room)


  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat div.messages:first').slideDown 100, ->
      $(this).remove()

  createGuestUser: =>
    rand_num = Math.floor(Math.random()*1000)
    @user = new Chat.User("Guest_" + rand_num)
    $('#username').html @user.user_name
    $('input#user_name').val @user.user_name
    @dispatcher.trigger 'new_user', @user.serialize()