class CarRecommendationsController < ApplicationController
  include Pagy::Backend

  before_action :validate_params, :ensure_user_exists!

  def index
    @pagy, @cars = pagy CarRecommendationService.new(**query_params).call
  end

  private

  def ensure_user_exists!
    User.find @valid_params[:user_id]
  end

  def query_params
    @valid_params.except :page
  end
end
