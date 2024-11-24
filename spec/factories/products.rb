FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    image { 'https://picsum.photos/480/360?random=' + Random.new.rand(1..100).to_s }
    description { "This is a sample product." }
    price { 100.0 }
    status { [true, false].sample }
    metadata { { param_1: "Taylor" } }
    stock_quantity { rand(10..1000) }
    association :category
  end
end
