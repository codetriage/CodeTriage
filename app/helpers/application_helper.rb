module ApplicationHelper
  WARNING_SVG = %Q{
    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="16px" height="16px" viewBox="0 0 16 16" class="issue-icon">
      <path style="fill-rule:evenodd;clip-rule:evenodd;" d="M8,0C3.582,0,0,3.582,0,8s3.582,8,8,8s8-3.582,8-8S12.418,0,8,0z M8,14 c-3.309,0-6-2.692-6-6s2.691-6,6-6c3.307,0,6,2.692,6,6S11.307,14,8,14z"/>
      <path style="fill-rule:evenodd;clip-rule:evenodd;" d="M8.5,3h-1C7.224,3,7,3.224,7,3.5v6C7,9.776,7.224,10,7.5,10h1 C8.776,10,9,9.776,9,9.5v-6C9,3.224,8.776,3,8.5,3z"/>
      <path style="fill-rule:evenodd;clip-rule:evenodd;" d="M8.5,11h-1C7.224,11,7,11.224,7,11.5v1C7,12.776,7.224,13,7.5,13h1 C8.776,13,9,12.776,9,12.5v-1C9,11.224,8.776,11,8.5,11z"/>
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
end
