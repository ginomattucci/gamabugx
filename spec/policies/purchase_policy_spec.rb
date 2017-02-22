require 'rails_helper'

describe PurchasePolicy do

  let!(:user) { build(:user) }
  let!(:purchase) { Purchase.new(user: user) }

  subject { described_class }

  permissions :index? do
    it { is_expected.to permit(user, purchase) }
    it { is_expected.not_to permit(nil, purchase) }
  end

  permissions :create? do
    it { is_expected.to permit(user, purchase) }
    it { is_expected.not_to permit(nil, purchase) }
  end

  permissions :success? do
    it { is_expected.to permit(user, purchase) }
    it { is_expected.not_to permit(nil, purchase) }
    it { is_expected.not_to permit(User.new, purchase) }
  end
end
