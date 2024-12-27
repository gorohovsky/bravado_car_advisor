FactoryBot.define do
  factory :car do
    brand
    model { Faker::Vehicle.unique.model }
    sequence(:price) { |n| 10_000 + n }

    transient do
      brand_name { nil }
    end

    trait :with_brand do
      brand { create(:brand, name: brand_name) }
    end
  end
end
