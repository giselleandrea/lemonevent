class AuthenticationController < ApplicationController
    skip_before_action :authenticate_request, only: :authenticate

    def authenticate
        user = User.find_by(email: params[:email])

        if user && user.authenticate(params[:password])
            token = JsonWebToken.encode(user_id: user.id)
            render json: { auth_token: token }, status: :ok
        else
            render json: { error: 'Invalido email o password' }, status: :unauthorized
        end
    end

end
