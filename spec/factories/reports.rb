FactoryBot.define do
  factory :report do
    user { nil }
    reason { "MyText" }
    status { 1 }
  end
end
