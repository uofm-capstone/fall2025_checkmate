module AdminHelper
  def assignable_roles_for(user, current_user)
    roles = []

    roles << 'admin' if !user.admin? && current_user.admin?
    roles << 'ta' if !user.ta? && (current_user.admin? || current_user.ta?)
    roles << 'student' if !user.student?
    roles << 'guest' if !user.guest?

    roles
  end

  def role_badge(user)
    role = user.role
    badge_class = "role-#{role}"
    label = role.to_s.titleize

    content_tag(:span, label, class: "role-badge #{badge_class}")
  end

end
