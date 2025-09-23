FactoryBot.define do
  factory :moderation_record do
    association :admin, factory: [ :user, :admin ]
    association :article

    admin_reason { "Content violated community guidelines." }
    status { :hidden }

    trait :pending_review do
      status { :pending_review }
      author_note { "I have updated the article, please review." }
    end
    trait :rejected do
      status { :rejected }
      rejection_reason { "The changes were not sufficient." }
    end
  end
end
