class CarRecommendationsController < ApplicationController
  include Pagy::Backend

  before_action :validate_params, :set_user

  def index
    @pagy, @cars = pagy CarRecommendationService.new(@user).call
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
