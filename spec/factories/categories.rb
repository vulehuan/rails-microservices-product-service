FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    status { [true, false].sample }
  end
end
