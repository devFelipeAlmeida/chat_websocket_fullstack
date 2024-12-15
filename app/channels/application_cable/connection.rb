module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]&.sub(/^Bearer\s/, "") # Remove o prefixo 'Bearer'
      Rails.logger.info "Token recebido: #{token}"

      begin
        # Decodifica o token JWT
        decoded_token = JWT.decode(
          token,
          Rails.application.credentials.fetch(:secret_key_base),
          true,
          algorithm: "HS256"
        )

        # Captura o payload do token
        payload = decoded_token[0]
        Rails.logger.info "Decoded token: #{payload}"

        # Valida expiração do token (se presente)
        if payload["exp"] && Time.at(payload["exp"]) < Time.now
          Rails.logger.warn "Token expirado"
          reject_unauthorized_connection
        end

        # Busca o usuário com base no ID do token
        user_id = payload["sub"]
        User.find_by(id: user_id) || reject_unauthorized_connection

      rescue JWT::DecodeError => e
        Rails.logger.error "Erro ao decodificar JWT: #{e.message}"
        reject_unauthorized_connection
      rescue => e
        Rails.logger.error "Erro de autenticação WebSocket: #{e.message}"
        reject_unauthorized_connection
      end
    end
  end
end
