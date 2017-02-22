require 'rails_helper'

RSpec.describe Highlight, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of :target }
  end
  describe 'Relations' do
    it { is_expected.to belong_to(:target) }
  end
end
