class UserMailer < ActionMailer::Base
  default :from => "noreply@authorly.com"

  def password_reset(user)
    @user = user

    mail :to => user.email, :subject => "Authorly - Password Reset"
  end

  def ios_compilation_completion_notification(to, index_url, ipa_url)
    @index_url = index_url
    @ipa_url   = ipa_url

    mail :to => to, :subject => "Authorly - Compilation of your iOS application has completed!"
  end

  def android_compilation_completion_notification(to, apk_url)
    @apk_url   = apk_url

    mail :to => to, :subject => "Authorly - Compilation of your Android application has completed!"
  end
end
