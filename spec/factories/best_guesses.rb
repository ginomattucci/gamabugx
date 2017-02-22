FactoryGirl.define do
  factory :best_guess do
    title "Best Guess Title"
    description_url "https://example.com"
    happens_at { Time.now }
    ends_at { 1.day.from_now }
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'best-guess.jpg'))  }
    question "Why did the chicken cross the road?"
    market_price 1000
  end
end
