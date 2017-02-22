FactoryGirl.define do
  factory :banner do
    url "https://example.com"
    title "My Banner"
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'auction.jpg'))  }
  end

end
