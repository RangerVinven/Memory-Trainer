class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
  respond_to :html, :json

  def create
    respond_to do |format|
      format.html { super }
      format.json do
        build_resource(sign_up_params)

        resource.save
        if resource.persisted?
          if resource.active_for_authentication?
            sign_up(resource_name, resource)
            render json: {
              message: 'Signed up successfully.',
              user: resource
            }, status: :created
          else
            expire_data_after_sign_in!
            render json: {
              message: "Signed up but #{resource.inactive_message}"
            }, status: :ok
          end
        else
          clean_up_passwords resource
          set_minimum_password_length
          render json: {
            message: "Sign up failed",
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end
end