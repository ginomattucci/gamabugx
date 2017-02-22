FactoryGirl.define do
  factory :statement do
    best_guess
    content "To get to the other side"
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'best-guess.jpg'))  }
    answer true
  end

end
