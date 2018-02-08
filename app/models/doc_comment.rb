class DocComment < ActiveRecord::Base
  belongs_to :doc_method, counter_cache: true
  belongs_to :doc_class, counter_cache: true

  validates :comment, uniqueness: { scope: [:doc_method_id, :doc_class_id] }
  validates :comment, presence:   true

  def doc_method?
    doc_method_id.present?
  end

  def md_safe_comment_block
    md = comment
    if md.match?(/^~~~|^```/)
      # If a comment starts with a code fence i.e. ~~~ or ```
      # Then indent the whole thing by one character
      # makes comments safe to use in markdown without
      # breaking out of code blocks
      md.gsub!(/^(.)/, ' \1')
    end
    md = DocMethod::NeedsDocs if md.blank?

    return "~~~\n#{md}\n~~~".html_safe
  end

  def doc_class?
    doc_class_id.present?
  end
end
