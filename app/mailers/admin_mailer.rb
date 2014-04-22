class AdminMailer < AbstractMailer
  default :from => '"Authorly" <no-reply@authorly.com>'

  def storybook_publication_completion_notification(to, storybook_id)
    @storybook = Storybook.find(storybok_id)

    mail :to => to, :subject => "Storybook '(#{@storybook.id}) #{@storybook.title}' was published to bookfair"
  end
end
