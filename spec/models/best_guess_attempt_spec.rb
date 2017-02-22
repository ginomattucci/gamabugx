require 'rails_helper'

RSpec.describe BestGuessAttempt, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :best_guess }

    context 'user_have_credits' do
      subject { build(:best_guess_attempt, user: user, best_guess: build(:best_guess, join_cost_in_credits: 5)) }

      context 'user without credits' do
        let!(:user) { create(:user, credits: 0) }
        it { is_expected.not_to be_valid }
      end

      context 'user with credits' do
        context 'user.credits > bid_cost_in_credits' do
          let!(:user) { create(:user, credits: 1000) }
          it { is_expected.to be_valid }
        end

        context 'user.credits == bid_cost_in_credits' do
          let!(:user) { create(:user, credits: 5) }
          it { is_expected.to be_valid }
        end

        context 'user.credits < bid_cost_in_credits' do
          let!(:user) { create(:user, credits: 3) }
          it { is_expected.not_to be_valid }
        end
      end
    end
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:best_guess) }
    it { is_expected.to have_many(:statement_answers) }
    it { is_expected.to have_many(:statements).through(:statement_answers) }
  end

  describe '#discount_user_credits' do
    it 'changes user credits' do
      user = create(:user, credits: 10)
      expect{ create(:best_guess_attempt, value_in_credits: 2, user: user) }.to change{user.credits}.from(10).to(8)
    end
  end

  describe '#set_value' do
    context 'With best_guess' do
      context 'with value_in_credits set' do
        it "doesn't change value_in_credits" do
          answer = build(:best_guess_attempt, user: build(:user), value_in_credits: 10_234)
          expect{ answer.valid? }.not_to change{ answer.value_in_credits }
        end
      end

      context 'wihout value_in_credits' do
        it 'Sets value_in_credits with `best_guess.join_cost_in_credits`' do
          answer = build(:best_guess_attempt, user: build(:user), best_guess: build(:best_guess, join_cost_in_credits: 19))
          answer.valid?
          expect(answer.value_in_credits).to eq(19)
        end
      end
    end

    context 'Without best_guess' do
      it "Doesn't change value_in_credits" do
        answer = build(:best_guess_attempt, user: build(:user), best_guess: nil)
        expect{ answer.valid? }.not_to change{ answer.value_in_credits }
      end
    end
  end
end
