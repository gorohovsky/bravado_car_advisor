class CarRecommendationService
  module Constants
    MIN_PRICE = 1
    MAX_PRICE = Float::INFINITY

    NULL_SUBSTITUTE = -1

    FIELDS_TO_SELECT = <<-SQL.freeze
      cars.id,
      cars.price,
      COALESCE(json.rank_score, #{NULL_SUBSTITUTE}) AS rank,
      cars.model,
      brands.id AS brand_id,
      brands.name AS brand_name,
      COALESCE((SELECT users.preferred_price_range @> cars.price::int8)::int, #{NULL_SUBSTITUTE}) AS label
    SQL

    JSON_JOIN = <<-SQL.freeze
      LEFT JOIN (
        SELECT
          (car.value->>'car_id')::bigint AS car_id,
          (car.value->>'rank_score')::float AS rank_score
        FROM
        json_array_elements('%s'::json) AS car(value)
      ) json
      ON cars.id = json.car_id
    SQL

    BRAND_FILTER = 'brands.name ILIKE ?'.freeze

    ORDER = 'label DESC, rank DESC, cars.price ASC'.freeze
  end
end
