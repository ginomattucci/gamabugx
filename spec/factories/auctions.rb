FactoryGirl.define do
  factory :auction do
    title "Auction Title"
    description_url "https://example.com"
    happens_at { Time.now }
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'auction.jpg'))  }
    market_price 1000
  end
end
