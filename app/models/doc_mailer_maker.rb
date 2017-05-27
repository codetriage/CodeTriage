class DocMailerMaker
  attr_accessor :user, :subs, :write_docs, :read_docs

  READY_FOR_NEXT_DEFAULT = Proc.new {|s| true }

  def initialize(user, subs, options = {}, &send_next)
    @user       = user
    @subs       = subs
    @write_docs = []
    @read_docs  = []
    assign_docs(&(send_next || READY_FOR_NEXT_DEFAULT))
  end

  def assign_doc_to_subscription(doc, sub)
    return if doc.blank?
    return doc if sub.doc_assignments.where(doc_method_id: doc.id).first
    ActiveRecord::Base.transaction do
      sub.doc_assignments.create!(doc_method_id: doc.id)
      sub.update_attributes(last_sent_at: Time.now)
    end
    doc
  end

  def assign_docs(&send_next)
    subs.flat_map do |sub|
      if !send_next.call(sub)
        logger.debug "Filtered: #{sub.inspect}"
        next
      end

      if sub.read?
        sub.unassigned_read_doc_methods.each do |doc|
          @read_docs  << assign_doc_to_subscription(doc, sub)
        end
      end

      if sub.write?
        sub.unassigned_write_doc_methods.each do |doc|
          @write_docs << assign_doc_to_subscription(doc, sub)
        end
      end
    end
  end

  def write_docs
    @write_docs.compact
  end

  def read_docs
    @read_docs.compact
  end

  def mail
    UserMailer.daily_docs(user: user, write_docs: write_docs, read_docs: read_docs)
  end

  def deliver
    if write_docs.blank? && read_docs.blank?
      logger.debug "No docs to send"
      return false
    end
    mail.deliver
  end
end
