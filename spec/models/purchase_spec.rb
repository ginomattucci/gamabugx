require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:plan) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:plan_credits) }
    it { is_expected.to validate_presence_of(:plan_price) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:invoice) }
    it { is_expected.to validate_presence_of(:invoice_url) }
    it { is_expected.to validate_presence_of(:payment_method) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to belong_to(:user) }
  end
end
