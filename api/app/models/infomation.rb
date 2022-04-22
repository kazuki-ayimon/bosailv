class Infomation < ApplicationRecord
  belongs_to :user, optional: true
  enum label: { Not: 0, Maintenance: 1, Hindrance: 2, Other: 99 }
  enum target: { All: 1, User: 2 }

  def target_user?(current_user)
    target == 'All' || (target == 'User' && current_user.present? && user_id == current_user.id)
  end
end