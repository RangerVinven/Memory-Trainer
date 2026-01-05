FactoryBot.define do
  factory :training_session do
    user { nil }
    training_type { "MyString" }
    training_data { "MyText" }
    recall_data { "MyText" }
    duration_seconds { 1 }
    item_count { 1 }
    accuracy_percentage { 1.5 }
    completed_at { "2026-01-05 19:06:13" }
  end
end
