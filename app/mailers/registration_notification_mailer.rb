class RegistrationNotificationMailer < ApplicationMailer
  default to: ENV.fetch("RECRUITMENT_EMAIL", "recruitment@example.com")

  def onboarding_completed(candidate_profile)
    @candidate_profile = candidate_profile
    mail(subject: "Candidate onboarding completed: #{candidate_profile.first_name} #{candidate_profile.last_name}")
  end
end
