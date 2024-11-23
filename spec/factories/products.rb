FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { "This is a sample product." }
    price { 100.0 }
    status { [true, false].sample }
    metadata { { param_1: "Taylor" } }
    association :category
  end
end
