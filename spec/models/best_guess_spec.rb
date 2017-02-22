require 'rails_helper'

RSpec.describe BestGuess, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :image }
    it { is_expected.to validate_presence_of :description_url }
    it { is_expected.to validate_presence_of :happens_at }
    it { is_expected.to validate_presence_of :ends_at }
    it { is_expected.to validate_presence_of :join_cost_in_credits }
    it { is_expected.to validate_presence_of :question }
    it { is_expected.to validate_presence_of :market_price }
    it { is_expected.to allow_value("http://example.com").for(:description_url) }
    it { is_expected.to allow_value("https://example.com").for(:description_url) }
    it { is_expected.to allow_value("https://www.example.com").for(:description_url) }
    it { is_expected.not_to allow_value("www.example.com").for(:description_url) }
    it { is_expected.not_to allow_value("example.com").for(:description_url) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:winner).class_name('User') }
    it { is_expected.to have_many(:statements) }
    it { is_expected.to have_many(:best_guess_attempts) }
    it { is_expected.to have_one(:prize_claim) }
  end

  describe 'Predicates' do
    subject { best_guess }

    context 'Active Best Guess' do
      let!(:best_guess) { build(:best_guess, ends_at: 1.minute.from_now, winner: nil, happens_at: 1.minute.ago) }
      it { is_expected.to be_active }
      it { is_expected.not_to be_finished }
      it { is_expected.not_to be_sold }
      it { is_expected.not_to be_scheduled }
      it { is_expected.not_to be_claimable }
    end

    context 'Scheduled Best Guess' do
      let!(:best_guess) { build(:best_guess, ends_at: 2.minute.from_now, winner: nil, happens_at: 1.minute.from_now) }
      it { is_expected.not_to be_active }
      it { is_expected.not_to be_finished }
      it { is_expected.not_to be_sold }
      it { is_expected.to be_scheduled }
      it { is_expected.not_to be_claimable }
    end

    context 'Finished Best Guess with a winner' do
      context 'Finished a month ago' do
        let!(:best_guess) { build(:best_guess, ends_at: 1.month.ago, winner: build(:user), happens_at: 2.months.minutes.ago, final_cost: 1.23) }
        it { is_expected.not_to be_active }
        it { is_expected.to be_finished }
        it { is_expected.to be_sold }
        it { is_expected.not_to be_scheduled }
        it { is_expected.not_to be_claimable }
      end
      context 'Finished 5 days ago' do
        let!(:best_guess) { build(:best_guess, ends_at: 5.days.ago, winner: build(:user), happens_at: 1.month.ago, final_cost: 1.23) }
        it { is_expected.not_to be_active }
        it { is_expected.to be_finished }
        it { is_expected.to be_sold }
        it { is_expected.not_to be_scheduled }
        it { is_expected.to be_claimable }
      end
    end

    context 'Finished Best Guess without a winner' do
      let!(:best_guess) { build(:best_guess, ends_at: 1.minute.ago, winner: nil, happens_at: 2.minutes.ago) }
      it { is_expected.not_to be_active }
      it { is_expected.not_to be_sold }
      it { is_expected.to be_finished }
      it { is_expected.not_to be_scheduled }
      it { is_expected.not_to be_claimable }
    end
  end

  describe '#check_winner' do
    subject { best_guess.check_winner }
    before { allow(GameNotification).to receive(:publish).and_return(nil) }

    context 'Unfinished game' do
      let!(:best_guess) { build(:best_guess, ends_at: 1.day.from_now) }

      it { is_expected.to be_falsey }
    end

    context 'Finished game' do
      before { allow_any_instance_of(BestGuessAttempt).to receive(:best_guess_is_active).and_return(true) }

      let!(:best_guess) { create(:best_guess, ends_at: 1.day.ago) }
      let!(:true_statement) { create(:statement, answer: true, best_guess: best_guess) }
      let!(:false_statement) { create(:statement, answer: false, best_guess: best_guess) }

      context 'With no attempts' do
        it { is_expected.to be_falsey }
      end

      context 'With attempts' do
        context 'With no finished attempt' do
          let!(:best_guess_attempt) { create(:best_guess_attempt, best_guess: best_guess) }

          it { is_expected.to be_falsey }
        end

        context 'With no correct attempt' do
          let!(:best_guess_attempt) { create(:best_guess_attempt, best_guess: best_guess, finished_at: 2.days.ago) }
          let!(:statement_wrong_answer) { create(:statement_answer, best_guess_attempt: best_guess_attempt, statement: true_statement, value: false)}

          it { is_expected.to be_falsey }
        end

        context 'With correct attempt' do
          before do
            allow(GameNotification).to receive(:publish).and_return(nil)
          end
          let!(:best_guess_attempt) { create(:best_guess_attempt, best_guess: best_guess, finished_at: 2.days.ago) }
          let!(:slower_best_guess_attempt) { create(:best_guess_attempt, best_guess: best_guess, finished_at: 1.days.ago) }
          let!(:statement_right_answer) { create(:statement_answer, best_guess_attempt: best_guess_attempt, statement: true_statement, value: true)}
          let!(:slower_statement_right_answer) { create(:statement_answer, best_guess_attempt: slower_best_guess_attempt, statement: true_statement, value: true)}

          it { is_expected.to eq best_guess_attempt.user }
        end
      end
    end
  end
end
