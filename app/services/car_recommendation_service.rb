class CarRecommendationService
  CAR_MATCH_LABEL = 'COALESCE((SELECT users.preferred_price_range @> cars.price::int8)::int, -1) AS label'.freeze
  FIELDS_TO_SELECT = %(
    cars.id,
    cars.price,
    cars.model,
    brands.id AS brand_id,
    brands.name AS brand_name,
    #{CAR_MATCH_LABEL}
  ).freeze
  BRAND_FILTER = 'brands.name ILIKE ?'.freeze
  ORDER = 'label DESC, cars.price ASC'.freeze

  MIN_PRICE = 1
  MAX_PRICE = Float::INFINITY

  def initialize(user_id:, query: nil, price_min: MIN_PRICE, price_max: MAX_PRICE)
    @user_id = user_id
    @brand_name = query
    @price_min = price_min
    @price_max = price_max
  end

  def call
    base_query
      .then { |query| join_tables(query) }
      .then { |query| apply_brand_filter(query) }
      .then { |query| apply_price_limits(query) }
      .then { |query| apply_order(query) }
  end

  private

  def base_query = Car.select FIELDS_TO_SELECT

  def join_tables(query)
    query.joins(:brand)
         .left_joins(brand: { user_preferred_brands: :user })
         .joins Arel.sql("AND users.id = #{@user_id}")
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
