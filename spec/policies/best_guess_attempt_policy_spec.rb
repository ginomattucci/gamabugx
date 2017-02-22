require 'rails_helper'

describe BestGuessAttemptPolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions :create? do
    it "denies access if guest user" do
      is_expected.not_to permit(nil, build(:best_guess_attempt))
    end

    context "signed user" do
      let!(:user) { create(:user) }
      let!(:best_guess) { create(:best_guess) }

      context 'best guess with attempts' do
        context 'Attempt user != current_user' do
          let(:other_user) { create(:user) }

          it "Denies access if attempt user != user" do
            is_expected.not_to permit(user, build(:best_guess_attempt, user: other_user, best_guess: best_guess))
          end
        end

        context 'User already attempted on best_guess' do
          let!(:previous_attempt) { create(:best_guess_attempt, user: user, best_guess: best_guess) }

          it "Denies access" do
            is_expected.not_to permit(user, build(:best_guess_attempt, user: user, best_guess: best_guess))
          end
        end

        context 'User without enough credits' do
          let(:user) { create(:user, credits: 1) }

          it "Denies access" do
            is_expected.not_to permit(user, build(:best_guess_attempt, user: user, best_guess: best_guess))
          end
        end

        context 'Only attempt with enough credits and from correct user' do
          let(:user) { create(:user, credits: 5) }
          let!(:best_guess) { create(:best_guess, join_cost_in_credits: 5) }
          it 'Allows access' do
            is_expected.to permit(user, build(:best_guess_attempt, user: user, best_guess: best_guess))
          end
        end
      end
    end
  end
end
