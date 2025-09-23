FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.sentence }
    association :user
    association :article
    parent { nil }

    trait :reply do
      # Usage: create(:comment, :reply, parent: some_other_comment)
      association :parent, factory: :comment
    end

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
