FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "email#{n}@test.com"
    end
    sequence :username do |n|
      "username#{n}"
    end
    password "123123123"
    credits 10
    cpf '123.123.123-12'
    document_id '123456789'
    address 'foo bar'
    birthday 18.years.ago
  end
end
