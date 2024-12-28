class CarRecommendationsController < ApplicationController
  include Pagy::Backend

  before_action :validate_params, :set_user

  def index
    @pagy, @cars = pagy CarRecommendationService.new(@user, **query_params).call
  end

  private

  def set_user
    @user = User.find @valid_params[:user_id]
  end

  def query_params
    @valid_params.except :user_id, :page
  end
end
