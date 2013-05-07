class UserMailer < ActionMailer::Base
  default :from => '"Authorly" <no-reply@authorly.com>'

  def password_reset(user)
    @user = user

    mail :to => user.email, :subject => "Password Reset"
  end

  def ios_compilation_completion_notification(to, index_url, ipa_url)
    @index_url = index_url
    @ipa_url   = ipa_url

    mail :to => to, :subject => "Authorly - Your iOS app is ready for testing!"
  end

  def android_compilation_completion_notification(to, apk_url)
    @apk_url   = apk_url

    mail :to => to, :subject => "Authorly - Your Android app is ready for testing!"
  end
end
