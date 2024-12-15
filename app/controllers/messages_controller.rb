class MessagesController < ApplicationController
  before_action :set_chat_room

  def index
    messages = @chat_room.messages.includes(:user).order(created_at: :asc)
    render json: messages.map { |message|
      {
        id: message.id,
        content: message.content,
        user: {
          id: message.user.id,
          username: message.user.username,
          email: message.user.email
        },
        created_at: message.created_at
      }
    }, status: :ok
  end

  def create
    @message = @chat_room.messages.build(message_params)

    if @message.save
      # Transmite a mensagem para o canal correspondente via WebSocket
      ActionCable.server.broadcast("chat_room_#{@chat_room.id}", {
        content: @message.content,
        user: {
          id: @message.user.id,
          username: @message.user.username,
          email: @message.user.email
        },
        created_at: @message.created_at.strftime("%Y-%m-%d %H:%M:%S")
      })

      render json: {
        message: "Message created successfully.",
        data: {
          id: @message.id,
          content: @message.content,
          user: {
            id: @message.user.id,
            username: @message.user.username,
            email: @message.user.email
          },
          created_at: @message.created_at.strftime("%Y-%m-%d %H:%M:%S")
        }
      }, status: :created
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_chat_room
    @chat_room = ChatRoom.find(params[:chat_room_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Chat room not found" }, status: :not_found
  end

  def message_params
    params.require(:message).permit(:content, :user_id)
  end
end