# frozen_string_literal: true

class University < Frontmatter::Page
  def self.section(section)
    all.select { _1.section == section }
  end
end
