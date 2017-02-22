class RemoveUserIdFromStatementAnswer < ActiveRecord::Migration
  def change
    remove_reference :statement_answers, :user, index: true
  end
end
