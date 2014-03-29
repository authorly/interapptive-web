class UserMailer < ActionMailer::Base
  default :from => '"Authorly" <no-reply@authorly.com>'

  def password_reset(user_id)
    @user = User.find(user_id)

    mail :to => @user.email, :subject => "Password Reset"
  end

  def email_confirmation(user_id)
    @user = User.find(user_id)
    mail :to => @user.email, :subject => "You're almost there! Please confirm your email"
  end

  def password_reset_notification(user_id, pass)
    @user = User.find_by_id(user_id)
    @pass = pass
    if @user
      mail :to => @user.email, :subject => "You are invited to use Authorly!"
    end
  end

  def ios_compilation_completion_notification(to, index_url, ipa_url)
    @index_url = index_url
    @ipa_url   = ipa_url

    mail :to => to, :subject => "Your iOS app is ready for testing!"
  end

  def android_compilation_completion_notification(to, apk_url)
    @apk_url   = apk_url

    mail :to => to, :subject => "Your Android app is ready for testing!"
  end

  def storybook_resource_archive_completion_notification(to, url)
    @resource_url   = url

    mail :to => to, :subject => "Your Storybook resource archive is ready for download"
  end
end
