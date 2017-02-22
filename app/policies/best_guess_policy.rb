class BestGuessPolicy < ApplicationPolicy
  def show?
    record.present?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
