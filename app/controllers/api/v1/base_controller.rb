module Api
  module V1
    class BaseController < ActionController::API
      # Use Devise for authentication, but don't redirect
      before_action :authenticate_user!
      
      # Respond only to JSON
      respond_to :json
    end
  end
end
