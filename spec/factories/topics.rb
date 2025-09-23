FactoryBot.define do
  factory :topic do
    sequence(:name) { |n| "#{Faker::Book.genre} #{n}" }
  end
end
