module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json
        skip_before_action :verify_authenticity_token
        skip_before_action :require_no_authentication, only: [:create]
        before_action :authenticate_user!, only: [:show]

        def create
          # Ensure a clean state by signing out any existing user
          sign_out(:user) if current_user

          self.resource = warden.authenticate(auth_options)
          if resource
            sign_in(resource_name, resource)
            render json: { message: 'Logged in successfully', user: resource }, status: :ok
          else
            render json: { error: 'Invalid credentials' }, status: :unauthorized
          end
        end

        def show
          render json: { user: current_user }, status: :ok
        end
      end
    end
  end
end
