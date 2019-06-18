# frozen_string_literal: true

module ApplicationHelper
  WARNING_SVG = %Q{
<?xml version="1.0" encoding="UTF-8"?>
<svg width="16px" height="16px" class="issue-icon" version="1.1" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
<path d="m8 0c-4.418 0-8 3.582-8 8s3.582 8 8 8 8-3.582 8-8-3.582-8-8-8zm0 14c-3.309 0-6-2.692-6-6s2.691-6 6-6c3.307 0 6 2.692 6 6s-2.693 6-6 6z" clip-rule="evenodd" fill-rule="evenodd"/>
<path d="M8.5,3h-1C7.224,3,7,3.224,7,3.5v6C7,9.776,7.224,10,7.5,10h1 C8.776,10,9,9.776,9,9.5v-6C9,3.224,8.776,3,8.5,3z" clip-rule="evenodd" fill-rule="evenodd"/>
<path d="M8.5,11h-1C7.224,11,7,11.224,7,11.5v1C7,12.776,7.224,13,7.5,13h1 C8.776,13,9,12.776,9,12.5v-1C9,11.224,8.776,11,8.5,11z" clip-rule="evenodd" fill-rule="evenodd"/>
</svg>
}.html_safe

  STAR_SVG = %Q{
    <svg version="1.1" xmlns="//www.w3.org/2000/svg" width="16px" height="16px" viewBox="0 0 16 16" class="star-icon">
      <polygon fill="white" stroke="white" stroke-width="2" points="8,3 12,13 3,7 13,7 4,13" />
    </svg>
  }.html_safe

  def flash_class(level)
    case level
    when :notice then 'info'
    when :error then 'error'
    when :alert then 'warning'
    end
  end

  def warning_svg
    WARNING_SVG
  end

  def star_svg
    STAR_SVG
  end
end
