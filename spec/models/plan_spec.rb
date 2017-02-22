require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:credits) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_numericality_of(:credits).only_integer }
    it { is_expected.to validate_numericality_of(:price) }

    %i(credits price).each do |attr|
      it { is_expected.to allow_value(1).for(attr) }
      it { is_expected.to allow_value(100).for(attr) }
      it { is_expected.not_to allow_value(-1).for(attr) }
      it { is_expected.not_to allow_value(0).for(attr) }
    end
  end
end
