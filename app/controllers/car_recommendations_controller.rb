class CarRecommendationsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @cars = pagy Car.all
  end
end
