FactoryBot.define do
  factory :car do
    brand
    model { Faker::Vehicle.unique.model }
    sequence(:price) { |n| 10_000 + n }
  end
end
