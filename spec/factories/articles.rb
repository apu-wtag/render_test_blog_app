FactoryBot.define do
  factory :article do
    title { Faker::Book.title }
    content {
      {
        "time": Time.now.to_i,
        "blocks": [
          {
            "id": SecureRandom.alphanumeric(10),
            "type": "paragraph",
            "data": { "text": Faker::Lorem.paragraph(sentence_count: 5) }
          }
        ],
        "version": "2.31.0"
      }.to_json
    }
    association :user
    association :topic
    trait :discarded do
      discarded_at { Time.current }
    end
    trait :archived do
      archived_at { Time.current }
    end
    trait :with_comments do
      transient do
        comments_count { 1 }
      end
      after(:create) do |article, evaluator|
        create_list(:comment, evaluator.comments_count, article: article)
        article.reload
      end
    end
  end
end
