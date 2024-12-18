import React, { useState } from 'react';
import {
    MessageCircle,
    User,
    Search,
    Send
} from 'lucide-react';

const mockUsers = [
    { id: 1, name: 'Silvo', lastMessage: 'Hello, everything is fine?', unreadCount: 2, avatar: 'https://i.pravatar.cc/150?u=1' },
    { id: 2, name: 'Maria Souza', lastMessage: 'Can you help me ?', unreadCount: 1, avatar: 'https://i.pravatar.cc/150?u=2' },
    { id: 3, name: 'Pedro Santos', lastMessage: 'Combined!', unreadCount: 0, avatar: 'https://i.pravatar.cc/150?u=3' }
];

const mockMessages = {
    1: [
        { id: 1, text: 'Hello, everything is fine?', sender: 'Silvo', timestamp: '10:30' },
        { id: 2, text: 'Everything yes, and you?', sender: 'You', timestamp: '10:31' }
    ],
    2: [
        { id: 1, text: 'I need your help', sender: 'Maria Souza', timestamp: '14:45' },
        { id: 2, text: 'Of course, count on me', sender: 'You', timestamp: '14:46' }
    ]
};

const ChatRoom = () => {
    const [selectedUser, setSelectedUser] = useState(null);
    const [messageInput, setMessageInput] = useState('');

    const handleUserSelect = (user) => {
        setSelectedUser(user);
    };

    const handleSendMessage = () => {
        if (messageInput.trim() && selectedUser) {
            // Lógica para enviar mensagem
            setMessageInput('');
        }
    };

    return (
        <div className='flex h-screen bg-gray-100'>

            {/* Sidebar */}
            <div className="w-80 bg-white border-r border-gray-200 p-4">
                <div className="flex items-center mb-6">
                    <MessageCircle className="mr-2 text-blue-500" />
                    <h2 className="text-xl font-bold">Messages</h2>
                </div>

                {/* Searchbar */}
                <div className="relative mb-4">
                    <input
                        type="text"
                        placeholder="Buscar contatos"
                        className="w-full p-2 pl-8 border rounded-lg"
                    />
                    <Search className="absolute left-2 top-3 text-gray-400" />
                </div>

                {/* User list */}
                <div className="space-y-2">
                    {mockUsers.map(user => (
                        <div key={user.id}
                            className={`flex items-center p-3 rounded-lg cursor-pointer hover:bg-gray-100 ${selectedUser?.id === user.id ? 'bg-blue-50' : ''}`}
                            onClick={() => handleUserSelect(user)}>
                            <img
                                src={user.avatar}
                                alt={user.name}
                                className="w-12 h-12 rounded-full mr-4"
                            />
                            <div className="flex-1">
                                <div className="flex justify-between items-center">
                                    <span className="font-semibold">{user.name}</span>
                                    {user.unreadCount > 0 && (
                                        <span className="bg-blue-500 text-white text-xs px-2 py-1 rounded-full">
                                            {user.unreadCount}
                                        </span>
                                    )}
                                </div>
                                <p className="text-sm text-gray-500 truncate">{user.lastMessage}</p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            {/* Chat Principal */}
            <div className="flex-1 flex flex-col">
                {selectedUser ? (
                    <>
                        {/* Cabeçalho do Chat */}
                        <div className="bg-white border-b p-4 flex items-center">
                            <img
                                src={selectedUser.avatar}
                                alt={selectedUser.name}
                                className="w-10 h-10 rounded-full mr-4"
                            />
                            <h3 className="text-lg font-semibold">{selectedUser.name}</h3>
                        </div>

                        {/* Área de Mensagens */}
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            {mockMessages[selectedUser.id]?.map(msg => (
                                <div
                                    key={msg.id}
                                    className={`flex ${msg.sender === 'Você' ? 'justify-end' : 'justify-start'}`}
                                >
                                    <div className={`
                    max-w-[70%] p-3 rounded-lg 
                    ${msg.sender === 'Você'
                                            ? 'bg-blue-500 text-white'
                                            : 'bg-gray-200 text-black'}
                  `}>
                                        <p>{msg.text}</p>
                                        <span className="text-xs opacity-70 block text-right mt-1">
                                            {msg.timestamp}
                                        </span>
                                    </div>
                                </div>
                            ))}
                        </div>

                        {/* Input de Mensagem */}
                        <div className="bg-white p-4 border-t flex items-center">
                            <input
                                type="text"
                                placeholder="Digite sua mensagem..."
                                value={messageInput}
                                onChange={(e) => setMessageInput(e.target.value)}
                                className="flex-1 p-2 border rounded-lg mr-2"
                            />
                            <button
                                onClick={handleSendMessage}
                                className="bg-blue-500 text-white p-2 rounded-full hover:bg-blue-600"
                            >
                                <Send size={20} />
                            </button>
                        </div>
                    </>
                ) : (
                    <div className="flex-1 flex items-center justify-center text-gray-500">
                        Selecione um usuário para iniciar o chat
                    </div>
                )}
            </div>
        </div>
    )
}

export default ChatRoom