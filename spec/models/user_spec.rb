require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username) }
    it { is_expected.to allow_value("foobar").for(:username) }
    it { is_expected.to allow_value("foobar123").for(:username) }
    it { is_expected.to allow_value("123123").for(:username) }
    it { is_expected.not_to allow_value("foo bar").for(:username) }
    it { is_expected.not_to allow_value("foo-bar").for(:username) }
    it { is_expected.not_to allow_value("foo-bár").for(:username) }
  end

  describe '#active_for_authentication?' do
    subject { user.active_for_authentication? }

    context 'Blocked user' do
      let!(:user) { build(:user, blocked: true) }

      it { is_expected.to be false }
    end

    context 'Regular User' do
      let!(:user) { build(:user, blocked: false) }

      it { is_expected.to be true }
    end
  end
end
