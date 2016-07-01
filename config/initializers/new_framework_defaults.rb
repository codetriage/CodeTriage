# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.0 upgrade.
# They will be removed in the next major Rails version.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Rails 5.0 release notes for more info on each option.

# Enable per-form CSRF tokens. Next major version defaults to true.
Rails.application.config.action_controller.per_form_csrf_tokens = true

# Enable origin-checking CSRF mitigation. Next major version defaults to true.
Rails.application.config.action_controller.forgery_protection_origin_check = true

# Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
ActiveSupport.to_time_preserves_timezone = true

# Require `belongs_to` associations by default. Next major version defaults to true.
Rails.application.config.active_record.belongs_to_required_by_default = false

# Do not halt callback chains when a callback returns false. Next major version defaults to false.
ActiveSupport.halt_callback_chains_on_return_false = true
