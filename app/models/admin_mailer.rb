class AdminMailer < ActionMailer::Base

  def group_approved(group)
    @subject    = 'Group Approved'
    @body["group"] = group
    @recipients = 'ssmith@cs.dal.ca'
    @from       = ADMIN_EMAIL
    @sent_on    = Time.now
  end

  def accepted(user, group)
    @subject    = 'Accepted to group'
    @body["group"]  = group
    @body["user"] = user
    @recipients = user.email
    @from       = ADMIN_EMAIL
    @sent_on    = Time.now
  end

  def account_created(user)
    @subject    = 'Account Created'
    @body["user"] = user
    @recipients = user.email
    @from       = ADMIN_EMAIL
    @sent_on    = Time.now
  end
end
