class CarRecommendationService
  def initialize(user)
    @user = user
  end

  def call
    Car
      .select("cars.id, cars.price, cars.model, brands.id AS brand_id, brands.name AS brand_name, #{label}")
      .joins(:brand)
      .left_joins(brand: { user_preferred_brands: :user })
      .joins(Arel.sql("AND users.id = #{@user.id}"))
      .order(Arel.sql('label DESC, cars.price ASC'))
  end

  private

  def label
    'COALESCE((SELECT users.preferred_price_range @> cars.price::int8)::int, -1) AS label'
  end
end
