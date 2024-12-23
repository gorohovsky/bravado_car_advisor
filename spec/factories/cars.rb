FactoryBot.define do
  factory :car do
    brand
    model { Faker::Vehicle.unique.model }
    price { 10_000 }
  end
end
