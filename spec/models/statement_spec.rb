require 'rails_helper'

RSpec.describe Statement, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of :content }
  end
end
