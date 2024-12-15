class CreateChatRoomsUsersJoinTable < ActiveRecord::Migration[7.2]
  def change
    create_join_table :chat_rooms, :users do |t|
      t.index :chat_room_id
      t.index :user_id
    end
  end
end
