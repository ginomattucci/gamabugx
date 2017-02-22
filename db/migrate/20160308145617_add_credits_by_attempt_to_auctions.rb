class AddCreditsByAttemptToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :credits_by_attempt, :integer
  end
end
