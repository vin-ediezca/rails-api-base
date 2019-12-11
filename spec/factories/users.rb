FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "JSmith-#{n}" }
    sequence(:name) { |n| "John Smith #{n}" }
    url { "http://example.com" }
    avatar_url { "http://example.com/avatar" }
    provider { "github" }
  end
end
