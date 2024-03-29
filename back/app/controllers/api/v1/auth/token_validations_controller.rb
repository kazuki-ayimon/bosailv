class Api::V1::Auth::TokenValidationsController < DeviseTokenAuth::TokenValidationsController
  include DeviseTokenAuth::Concerns::SetUserByToken
  skip_before_action :verify_authenticity_token
  prepend_before_action :update_request_uid_header

  # GET /api/v1/auth/validate_token(.json) トークン検証API(処理)
  # def validate_token
  #   super
  # end

  protected

  def render_validate_token_success
    render './api/v1/auth/success'
  end

  def render_validate_token_error
    render './api/v1/failure', locals: { alert: I18n.t('devise_token_auth.token_validations.invalid') }, status: :unauthorized
  end
end
