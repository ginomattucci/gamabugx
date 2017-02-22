FactoryGirl.define do
  factory :prize_claim do
    user
    target factory: :auction
    full_name "John Doe"
    deliver_address "Sesame Street, 1234"
    phone_number "(12)3456-7890"
  end
end
