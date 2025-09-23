FactoryBot.define do
  factory :report do
    reason { Faker::Lorem.paragraph }
    status { :pending }
    association :user
    association :reportable, factory: :article

    trait :for_comment do
      # Usage: create(:report, :for_comment)
      association :reportable, factory: :comment
    end
  end
end
