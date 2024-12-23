class User < ApplicationRecord
  has_many :user_preferred_brands, dependent: :destroy
  has_many :preferred_brands, through: :user_preferred_brands, source: :brand

  validates :email, presence: true
  validates :email, uniqueness: true
  validates :preferred_price_range, presence: true

  CACHE_KEY_TEMPLATE = 'user_ai_car_suggestions/%s'.freeze
  CACHE_TTL = 24.hours

  def ai_car_suggestions
    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      SuggestionsApi::Client.new(id).perform
    end
  end

  private

  def cache_key
    format(CACHE_KEY_TEMPLATE, id)
  end
end
