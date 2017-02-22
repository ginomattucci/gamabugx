require 'rails_helper'

describe PrizeClaimPolicy do

  let(:user) { create(:user) }

  subject { described_class }

  permissions :new? do
    it "denies access if guest user" do
      is_expected.not_to permit(nil, build(:prize_claim))
    end

    it "denies access if not winner" do
      is_expected.not_to permit(user, build(:prize_claim))
    end

    it "allows if winner and target is claimable" do
      user = create(:user)
      is_expected.to permit(user, build(:prize_claim, user: user, target: create(:auction, winner: user, ended_at: 1.minute.ago)))
    end
  end
end
