require 'rails_helper'

describe PlanPolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions :index? do
    it { is_expected.to permit(user) }
  end
end
