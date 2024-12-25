module ParamValidations
  module CarRecommendations
    class Index < Dry::Validation::Contract
      params do
        required(:user_id).filled(:integer, gt?: 0)
        optional(:query).filled(:string)
        optional(:price_min).filled(:integer, gt?: 0)
        optional(:price_max).filled(:integer, gt?: 0)
        optional(:page).filled(:integer, gt?: 0)
      end

      rule(:price_max, :price_min) do
        if values[:price_max] && values[:price_min] && values[:price_max] < values[:price_min]
          key.failure('must be greater than or equal to price_min')
        end
      end
    end
  end
end
