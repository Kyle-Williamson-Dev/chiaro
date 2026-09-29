class ProfilePolicy < ApplicationPolicy
  def show?
    user.present?
  end

  def update?
    record.user_id == user.id || user.admin_role?
  end

  def edit?
    update?
  end
end