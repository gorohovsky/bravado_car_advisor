FactoryBot.define do
  factory :brand do
    name { Faker::Vehicle.manufacturer }
  end
end
