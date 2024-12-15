class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_room_#{params[:chat_room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = Message.create!(
      content: data['content'],
      user_id: current_user.id,
      chat_room_id: params[:chat_room_id]
    )
    ActionCable.server.broadcast(
      "chat_room_#{params[:chat_room_id]}",
      {
        content: message.content,
        user: {
          email: current_user.email,
          username: current_user.username # Inclui username
        },
        created_at: message.created_at
      }
    )
  end
end
