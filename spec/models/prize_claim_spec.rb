require 'rails_helper'

RSpec.describe PrizeClaim, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :target }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :deliver_address }
    it { is_expected.to validate_presence_of :phone_number }

    context "user claiming a prize" do
      subject { prize_claim }
      let!(:user) {build(:user)}
      let!(:prize_claim) { build(:prize_claim, target: target, user: user) }

      context 'claimer is the winner' do
        context 'claiming too late' do
          let!(:target) { build(:best_guess, winner: user, ends_at: 8.days.ago) }

          it { is_expected.not_to be_valid }
        end
        context 'claiming on time' do
          let!(:target) { build(:auction, winner: user, ended_at: 5.days.ago) }

          it { is_expected.to be_valid }
        end
      end

      context 'target has no winner' do
        let!(:target) { build(:auction, winner: nil) }

        it { is_expected.not_to be_valid }
      end

      context 'target has another winner' do
        let!(:target) { build(:best_guess, winner: build(:user)) }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:target) }
  end
end
