class CandidateProfile < ApplicationRecord
  belongs_to :user

  has_many :candidate_documents, dependent: :destroy
  has_many :educations, dependent: :destroy
  has_many :work_experiences, dependent: :destroy
  has_many :candidate_skills, dependent: :destroy
  has_many :skills, through: :candidate_skills
  has_many :candidate_languages, dependent: :destroy
  has_many :languages, through: :candidate_languages

  accepts_nested_attributes_for :educations, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :work_experiences, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :candidate_languages, allow_destroy: true, reject_if: :all_blank

  serialize :preferred_regions, coder: JSON, type: Array
  serialize :transport_types, coder: JSON, type: Array
  serialize :employment_types, coder: JSON, type: Array
  serialize :available_working_days, coder: JSON, type: Array
  serialize :unknown_skills, coder: JSON, type: Array

  JOB_FUNCTIONS = [
    "General dentist",
    "Dental hygienist",
    "Dental assistant",
    "Prevention assistant",
    "Paro-prevention assistant",
    "Orthodontic assistant",
    "Front-office / receptionist",
    "Practice manager",
    "Dental technician",
    "Specialist"
  ].freeze

  SEARCH_STATUSES = ["Active", "Passive", "Inactive"].freeze
  REGIONS = ["Amsterdam", "Rotterdam", "Utrecht", "The Hague", "North Brabant", "Gelderland", "Limburg", "Remote / flexible"].freeze
  TRANSPORT_TYPES = ["Bike", "Scooter", "Public transport", "Car"].freeze
  EMPLOYMENT_TYPES = ["Employed", "Self-employed", "Freelance", "Percentage-based"].freeze
  BIG_STATUSES = ["BIG registered", "In progress", "Under supervision", "Not applicable"].freeze
  WORKING_DAYS = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].freeze

  validates :first_name, :last_name, :email, :phone_number, :city, :desired_job_function,
            :maximum_travel_time, :search_status, :years_of_experience, :available_from,
            presence: true, if: :completed?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone_number, format: { with: /\A(?:\+|00)?[\d\s().-]{7,}\z/ }, allow_blank: true
  validates :desired_job_function, inclusion: { in: JOB_FUNCTIONS }, allow_blank: true
  validates :search_status, inclusion: { in: SEARCH_STATUSES }, allow_blank: true
  validates :maximum_travel_time, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validates :years_of_experience, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validates :desired_gross_salary, :average_daily_revenue, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :desired_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true
  validates :big_number, presence: true, if: -> { completed? && big_registration_status == "BIG registered" }
  validates :consent_accepted, acceptance: true, if: :completed?
  validate :required_checkbox_values, if: :completed?

  before_validation :normalize_checkbox_values
  before_validation :clear_irrelevant_compensation_fields

  def available_working_days_list
    parse_array(available_working_days)
  end

  def preferred_regions_list
    parse_array(preferred_regions)
  end

  def employment_types_list
    parse_array(employment_types)
  end

  def transport_types_list
    parse_array(transport_types)
  end

  def unknown_skills=(value)
    super(value.is_a?(String) ? value.split(",").map(&:strip).reject(&:blank?) : value)
  end

  def completed?
    completed_at.present?
  end

  def salary_relevant?
    employment_types_list.include?("Employed")
  end

  def percentage_relevant?
    (employment_types_list & ["Self-employed", "Freelance", "Percentage-based"]).any?
  end

  def big_registration_relevant?
    ["General dentist", "Dental hygienist", "Prevention assistant", "Paro-prevention assistant", "Specialist"].include?(desired_job_function)
  end

  private

  def required_checkbox_values
    errors.add(:preferred_regions, "select at least one") if preferred_regions_list.empty?
    errors.add(:employment_types, "select at least one") if employment_types_list.empty?
    errors.add(:available_working_days, "select at least one") if available_working_days_list.empty?
  end

  def normalize_checkbox_values
    self.preferred_regions = preferred_regions_list
    self.transport_types = transport_types_list
    self.employment_types = employment_types_list
    self.available_working_days = available_working_days_list
  end

  def clear_irrelevant_compensation_fields
    self.desired_gross_salary = nil unless salary_relevant?
    self.desired_percentage = nil unless percentage_relevant?

    return if big_registration_relevant?

    self.big_registration_status = "Not applicable"
    self.big_number = nil
  end

  def parse_array(value)
    return value.reject(&:blank?) if value.is_a?(Array)
    return [] if value.blank?

    JSON.parse(value).reject(&:blank?)
  rescue JSON::ParserError
    []
  end

end
