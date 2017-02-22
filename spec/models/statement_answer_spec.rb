require 'rails_helper'

RSpec.describe StatementAnswer, type: :model do
  describe 'Relations' do
    it { is_expected.to belong_to(:best_guess_attempt) }
    it { is_expected.to belong_to(:statement) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :best_guess_attempt }
    it { is_expected.to validate_presence_of :statement }
  end
end
