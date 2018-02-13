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
    md = DocMethod::NeedsDocs if md.blank?
    md
  end

  def doc_class?
    doc_class_id.present?
  end
end
