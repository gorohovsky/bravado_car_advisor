class CarRecommendationService
  include Constants

  def initialize(user, query: nil, price_min: MIN_PRICE, price_max: MAX_PRICE)
    @user = user
    @brand_name = query
    @price_min = price_min
    @price_max = price_max
    @car_ranks = AiSuggestionsService.new(@user).call
  end

  def call
    base_query
      .then { |query| join_tables(query) }
      .then { |query| join_car_ranks(query) }
      .then { |query| apply_brand_filter(query) }
      .then { |query| apply_price_limits(query) }
      .then { |query| apply_order(query) }
  end

  private

  def base_query = Car.select FIELDS_TO_SELECT

  def join_tables(query)
    query.joins(:brand)
         .left_joins(brand: { user_preferred_brands: :user })
         .joins Arel.sql("AND users.id = #{@user.id}")
  end

  def join_car_ranks(query)
    query.joins format(JSON_JOIN, car_ranks_json)
  end

  def car_ranks_json
    JSON.generate @car_ranks
  end

  def apply_brand_filter(query)
    @brand_name ? query.where(BRAND_FILTER, "#{@brand_name}%") : query
  end

  def apply_price_limits(query)
    query.where(cars: { price: @price_min..@price_max })
  end

  def apply_order(query)
    query.order Arel.sql(ORDER)
  end
end
