class UserPolicy < ApplicationPolicy
  def show?
    true
  end
  def update?
    user.present? && (record.user == user || user.admin?)
  end
  def destroy?
    user.admin?
  end
end
