class CommentPolicy < ApplicationPolicy
  def create?
    user.present?
  end
  def update?
    user.present? && (user.admin? || user.editor? || record.user == user)
  end
  def destroy?
    update?
  end
end
