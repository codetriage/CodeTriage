# frozen_string_literal: true

# Creates a mailer for +user+ with +subs+.
# +user+ is a User object, +subs+ is a collection of +Repo_Subscription+ objects tied to +user+
# +Repo_Subscription+ objects contain int +user_id+, int +repo_id+,
# datetime +last_sent_at+ (for email), int +email_limit+, bool +write+,
# bool +read+, int +write_limit+, and int +read_limit+.
#
# +#subs+ is an accessor for the collection of +Repo_Subscription+ objects pass to the class.
class DocMailerMaker
  attr_accessor :user, :subs, :write_docs, :read_docs

  READY_FOR_NEXT_DEFAULT = Proc.new { |_s| true }

  def initialize(user, subs, _options = {}, &send_next)
    @user       = user
    @subs       = subs
    @write_docs = []
    @read_docs  = []
    assign_docs(&(send_next || READY_FOR_NEXT_DEFAULT))
  end

  def empty?
    !any?
  end

  def any?
    @write_docs.present? || @read_docs.present?
  end

  # Updates documentation task metadata (+last_sent_at+) and assigns the doc to
  # the subscription.
  def assign_doc_to_subscription(doc, sub)
    return if doc.blank?
    return doc if sub.doc_assignments.where(doc_method_id: doc.id).first
    ActiveRecord::Base.transaction do
      sub.doc_assignments.create!(doc_method_id: doc.id)
      sub.update_attributes(last_sent_at: Time.now)
    end
    doc
  end

  # Assigns documentation tasks to a subscription
  def assign_docs()
    subs.flat_map do |sub|
      if !yield(sub)
        Rails.logger.debug "Filtered: #{sub.inspect}"
        next
      end

      # Both +sub.read?+ and +sub.write?+ statements will assign their respective type
      # to the appropriate subscription queue.
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

  # Modifies accessor +write_docs+ to compact on access.
  def write_docs
    @write_docs.compact
  end

  # Modifies accessor +read_docs+ to compact on access.
  def read_docs
    @read_docs.compact
  end

  # Sends email to +user+ containing current batch of +read_docs+ and +write_docs+.
  def mail
    UserMailer.daily_docs(user: user, write_docs: write_docs, read_docs: read_docs)
  end

  # Triggers mail delivery unless there are no +read_docs+ or +write_docs+ to mail
  # to the user.  Returns +false+ if there are no docs, else triggers mail delivery.
  def deliver
    if write_docs.blank? && read_docs.blank?
      Rails.logger.debug "No docs to send"
      return false
    end
    mail.deliver_later
  end

  def deliver_later
    if write_docs.blank? && read_docs.blank?
      Rails.logger.debug "No docs to send"
      return false
    end
    mail.deliver_later
  end
end
