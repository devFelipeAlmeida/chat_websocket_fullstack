class ChatRoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat_room, only: [ :show ]

  # Exibe uma sala de chat específica (inicializa mensagens)
  def show
    # Garantir que o usuário atual faz parte da sala de chat
    unless @chat_room.users.include?(current_user)
      return render json: { error: "You are not authorized to view this chat room" }, status: :forbidden
    end

    render json: {
      chat_room: {
        id: @chat_room.id,
        name: @chat_room.name,
        participants: @chat_room.users.select(:id, :email, :username)
      },
      messages: @chat_room.messages.includes(:user).map do |msg|
        {
          id: msg.id,
          content: msg.content,
          user_email: msg.user.email,
          user_username: msg.user.username, # Adiciona o username
          created_at: msg.created_at
        }
      end
    }
  end

  # Cria uma nova sala de chat entre dois usuários
  def create
    user_1 = User.find_by(id: params[:user_1_id])
    user_2 = User.find_by(id: params[:user_2_id])

    if user_1.nil? || user_2.nil?
      return render json: { error: "One or both users not found." }, status: :not_found
    end

    if user_1 == user_2
      return render json: { error: "Users must be different." }, status: :unprocessable_entity
    end

    # Verifica se já existe uma sala de chat entre esses dois usuários
    existing_chat_room = ChatRoom.joins(:users)
                                 .where(users: { id: [ user_1.id, user_2.id ] })
                                 .group("chat_rooms.id")
                                 .having("COUNT(DISTINCT users.id) = 2")
                                 .first

    if existing_chat_room
      return render json: {
        message: "Chat room already exists.",
        chat_room: {
          id: existing_chat_room.id,
          name: existing_chat_room.name
        }
      }, status: :ok
    end

    # Cria a nova sala de chat
    chat_room = ChatRoom.create!(name: "Chat between #{user_1.email} and #{user_2.email}")
    chat_room.users << [ user_1, user_2 ]

    render json: {
      message: "Chat room created successfully.",
      chat_room: {
        id: chat_room.id,
        name: chat_room.name,
        created_at: chat_room.created_at,
        updated_at: chat_room.updated_at
      }
    }, status: :created
  end

  # Lista as conversas privadas do usuário atual
  def index
    chat_rooms = current_user.chat_rooms.includes(:users).map do |chat_room|
      {
        id: chat_room.id,
        name: chat_room.name,
        participants: chat_room.users.select(:id, :email, :username)
      }
    end

    render json: { chat_rooms: chat_rooms }, status: :ok
  end

  private

  # Configura a sala de chat com base no ID
  def set_chat_room
    @chat_room = ChatRoom.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Chat room not found." }, status: :not_found
  end
end
