class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
  respond_to :html, :json

  def create
    respond_to do |format|
      format.html { super }
      format.json do
        self.resource = warden.authenticate(auth_options)
        
        if resource
          sign_in(resource_name, resource)
          render json: {
            message: 'Logged in successfully.',
            user: resource
          }, status: :ok
        else
          render json: {
            message: 'Invalid email or password.'
          }, status: :unauthorized
        end
      end
    end
  end

  def respond_to_on_destroy
    respond_to do |format|
      format.html { super }
      format.json do
        head :no_content
      end
    end
  end
end
