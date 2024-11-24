# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'faker'

categories = 5.times.map do
  Category.create!(name: Faker::Commerce.department)
end

100.times do
  Product.create!(
    name: Faker::Commerce.product_name,
    price: Faker::Commerce.price(range: 5.0..500.0, as_string: false),
    metadata: {
      brand: Faker::Company.name,
      color: Faker::Color.color_name,
      weight: "#{rand(1..10)}kg"
    },
    category_id: categories.sample.id,
    status: [true, false].sample,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    stock_quantity: rand(10..1000),
    lock_version: 0,
    image: 'https://picsum.photos/480/360?random=' + Random.new.rand(1..10000).to_s,
    created_at: Time.now,
    updated_at: Time.now
  )
end