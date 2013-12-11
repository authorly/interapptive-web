class ApplicationMailer < ActionMailer::Base
  default :from => '"Authorly" <no-reply@authorly.com>'

  def created(application_id)
    @application = Application.find(application_id)
    @storybook = @application.publish_request.storybook
    mail :to => @storybook.user.email, :subject => "Your storybook #{@storybook.title} was published to #{Application::PROVIDERS[@application.provider.to_sym]}"
  end
end
