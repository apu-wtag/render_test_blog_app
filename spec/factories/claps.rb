FactoryBot.define do
  factory :clap do
    association :user
    association :article
  end
end
