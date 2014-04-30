class ApplicationMailer < AbstractMailer
  default :from => '"Authorly" <no-reply@authorly.com>'

  def created(application_id)
    @application = Application.find(application_id)
    @storybook = @application.publish_request.storybook
    mail :to => @storybook.user.email, :subject => "Your storybook app (#{@storybook.title}) is available for purchase at #{Application::PROVIDERS[@application.provider.to_sym]}"
  end
end
