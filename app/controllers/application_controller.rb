class ApplicationController < ActionController::API
  include ParamsGuard

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_response

  private

  def record_not_found_response(error)
    render json: { error: error.message }, status: 404
  end
end
