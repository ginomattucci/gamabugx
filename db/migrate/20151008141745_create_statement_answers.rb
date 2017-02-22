class CreateStatementAnswers < ActiveRecord::Migration
  def change
    create_table :statement_answers do |t|
      t.boolean :value
      t.references :best_guess_attempt, index: true, foreign_key: true
      t.references :statement, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
