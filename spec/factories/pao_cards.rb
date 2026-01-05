FactoryBot.define do
  factory :pao_card do
    user { nil }
    suit { 1 }
    rank { 1 }
    person { "MyString" }
    action { "MyString" }
    object { "MyString" }
  end
end
