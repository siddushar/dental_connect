class CandidateOnboardingsController < ApplicationController
  before_action :set_profile, only: %i[edit update show]

  def new
    @profile = current_user.candidate_profile || current_user.build_candidate_profile(email: current_user.email)
    @document = @profile.candidate_documents.build
  end

  def create
    @profile = current_user.candidate_profile || current_user.build_candidate_profile(email: current_user.email)
    @document = @profile.candidate_documents.build(document_type: "cv", parsing_status: "pending")
    @document.file.attach(params.dig(:candidate_document, :file))

    unless accepted_consent?
      @document.errors.add(:base, "Please accept the consent checkbox before uploading.")
      return render :new, status: :unprocessable_entity
    end

    if @profile.save(validate: false) && @document.save
      ParseCandidateCvJob.perform_now(@document)
      redirect_to edit_candidate_onboarding_path, notice: upload_notice
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    prepare_form
  end

  def manual
    current_user.candidate_profile&.destroy

    redirect_to edit_candidate_onboarding_path, notice: "Manual onboarding started with a blank profile."
  end

  def update
    @profile.assign_attributes(profile_params)
    @profile.completed_at = Time.current

    if @profile.save
      RegistrationNotificationMailer.onboarding_completed(@profile).deliver_later
      
      redirect_to candidate_onboarding_path, notice: "Your candidate profile has been saved."
    else
      prepare_form
      render :edit, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def current_user
    User.find_or_create_by!(email: "candidate@example.com") do |user|
      user.name = "Demo Candidate"
    end
  end

  def set_profile
    @profile = current_user.candidate_profile || current_user.create_candidate_profile!
  end

  def prepare_form
    @profile.educations.build if @profile.educations.empty?
    @profile.work_experiences.build if @profile.work_experiences.empty?
    @profile.candidate_languages.build if @profile.candidate_languages.empty?
    @skills_by_group = Skill.order(:function_group, :name).group_by(&:function_group)
    @languages = Language.order(:name)
    @latest_document = @profile.candidate_documents.order(created_at: :desc).first
  end

  def upload_notice
    return "CV uploaded, but it could not be parsed. You can continue manually." if @document.parsing_status == "failed"

    "CV uploaded and analyzed. Please review the extracted profile details."
  end

  def accepted_consent?
    ActiveModel::Type::Boolean.new.cast(params.dig(:candidate_document, :consent_accepted))
  end

  def profile_params
    params.require(:candidate_profile).permit(
      :first_name, :last_name, :email, :phone_number, :city, :country,
      :desired_job_function, :maximum_travel_time, :search_status, :reason_for_looking,
      :desired_gross_salary, :desired_percentage, :average_daily_revenue,
      :big_registration_status, :big_number, :years_of_experience, :available_from,
      :notice_period, :motivation, :internal_notes, :professional_summary, :consent_accepted,
      preferred_regions: [], transport_types: [], employment_types: [], available_working_days: [],
      skill_ids: [],
      candidate_languages_attributes: %i[id language_id level _destroy],
      educations_attributes: %i[id institution study location level start_date end_date _destroy],
      work_experiences_attributes: %i[id job_title company_name responsibilities start_date end_date current_job _destroy]
    )
  end

end
