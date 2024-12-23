FactoryBot.define do
  factory :user do
    preferred_brands { [] }
    email { Faker::Internet.email }
    preferred_price_range { 10_000...20_000 }
  end
end
