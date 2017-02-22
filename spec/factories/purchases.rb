FactoryGirl.define do
  factory :purchase do
    plan
    user
    plan_name "MyString"
    plan_credits 1
    plan_price "9.99"
    status "MyString"
    invoice "MyString"
    invoice_url "MyString"
    payment_method "MyString"
  end
end
