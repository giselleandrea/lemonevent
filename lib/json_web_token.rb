require 'jwt'

class JsonWebToken
    def self.encode(payload, expiration = 4.hours.from_now)
        payload[:exp] = expiration.to_i
        JWT.encode(payload, Rails.application.credentials.secret_key_base)
    end

    def self.decode(token)
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        HashWithIndifferentAccess.new(decoded)
    rescue JWT::ExpiredSignature, JWT::DecodeError
        nil
    end
end
