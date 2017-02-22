require 'rails_helper'

describe AuctionAttemptPolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
