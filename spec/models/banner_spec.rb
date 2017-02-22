require 'rails_helper'

RSpec.describe Banner, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :image }
    it { is_expected.to validate_presence_of :url }
    it { is_expected.to allow_value("http://example.com").for(:url) }
    it { is_expected.to allow_value("https://example.com").for(:url) }
    it { is_expected.to allow_value("https://www.example.com").for(:url) }
    it { is_expected.not_to allow_value("www.example.com").for(:url) }
    it { is_expected.not_to allow_value("example.com").for(:url) }
  end
end
