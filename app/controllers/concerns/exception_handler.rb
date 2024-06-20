module ExceptionHandler
    extend ActiveSupport::Concern

    included do
        rescue_from ActiveRecord::RecordNotFound do |e|
            json_response({ message: e.message }, :not_found)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
            json_response({ message: e.message }, :unprocessable_entity)
        end

        rescue_from ExceptionHandler::MissingToken do |e|
            json_response({ message: e.message }, :unauthorized)
        end

        rescue_from ExceptionHandler::InvalidToken do |e|
            json_response({ message: e.message }, :unauthorized)
        end
    end

    # Método para formatear las respuestas JSON
    def json_response(message, status = :ok)
        render json: message, status: status
    end

    # Definición de las excepciones personalizadas
    class 
        MissingToken < StandardError; 
    end
    class 
        InvalidToken < StandardError; 
    end
end
