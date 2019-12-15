class AccessTokensController < ApplicationController
  skip_before_action :authorize!, only: [:create]

  def create
    authenticator = UserAuthenticator.new(params[:code])

    begin
      authenticator.perform
      access_token = AccessTokenSerializer.new(authenticator.access_token)

      render json: access_token, status: :created
    rescue UserAuthenticator::AuthenticationError
      authentication_error
    end
  end

  def destroy
    current_user.access_token.destroy
  end
end
