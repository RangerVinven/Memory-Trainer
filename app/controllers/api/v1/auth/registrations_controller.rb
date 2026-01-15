module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json
        skip_before_action :verify_authenticity_token
        before_action :authenticate_user!, only: [:update]

        def create
          build_resource(sign_up_params)
          resource.save
          if resource.persisted?
            if resource.active_for_authentication?
              sign_up(resource_name, resource)
              render json: { message: 'Signed up successfully', user: resource }, status: :ok
            else
              expire_data_after_sign_in!
              render json: { message: "Signed up but #{resource.inactive_message}" }, status: :ok
            end
          else
            clean_up_passwords resource
            set_minimum_password_length
            render json: { error: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
          
          if resource.update_with_password(account_update_params)
            bypass_sign_in resource, scope: resource_name
            render json: { message: 'Profile updated successfully', user: resource }, status: :ok
          else
            clean_up_passwords resource
            render json: { error: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def account_update_params
          params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
        end
      end
    end
  end
end