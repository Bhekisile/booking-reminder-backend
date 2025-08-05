FactoryBot.define do
  factory :invitation do
    email { "MyString" }
    token { "MyString" }
    organization { nil }
    inviter_id { 1 }
  end
end
