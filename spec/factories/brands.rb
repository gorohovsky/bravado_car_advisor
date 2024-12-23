FactoryBot.define do
  factory :brand do
    name { Faker::Vehicle.unique.manufacturer }
  end
end
