class UserMailer < ActionMailer::Base
  default :from => '"Authorly" <no-reply@authorly.com>'

  def password_reset(user)
    @user = user

    mail :to => user.email, :subject => "Authorly - Password Reset"
  end

  def compilation_completion_notification(to, index_url, ipa_url)
    @index_url = index_url
    @ipa_url   = ipa_url

    mail :to => to, :subject => "Authorly - Compilation of your application has completed!"
  end
end
