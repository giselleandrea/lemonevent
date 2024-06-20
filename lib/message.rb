module Message
    def self.missing_token
        'Token no proporcionado'
    end

    def self.invalid_token
        'Token no válido'
    end

    def self.invalid_credentials
        'Credenciales no válidas'
    end

    def self.account_created
        'Cuenta creada exitosamente'
    end

    def self.account_not_created
        'La cuenta no pudo ser creada'
    end

    def self.expired_token
        'Token expirado, por favor ingrese nuevamente'
    end
end
