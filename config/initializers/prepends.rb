# frozen_string_literal: true

# Default Hyrax behavior for permission badge is to show Institution name (in this case DCE)
require_relative '../prepends/custom_permission_badge'
Hyrax::PermissionBadge.prepend(CustomPermissionBadge)
