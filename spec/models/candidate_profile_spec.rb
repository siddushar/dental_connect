require "rails_helper"

RSpec.describe CandidateProfile, type: :model do
  it "requires key onboarding fields when completed" do
    profile = described_class.new(user: User.new(email: "candidate@example.com"), completed_at: Time.current)

    expect(profile).not_to be_valid
    expect(profile.errors[:email]).to include("can't be blank")
    expect(profile.errors[:city]).to include("can't be blank")
    expect(profile.errors[:preferred_regions]).to include("select at least one")
    expect(profile.errors[:employment_types]).to include("select at least one")
    expect(profile.errors[:available_working_days]).to include("select at least one")
  end

  it "accepts a complete valid onboarding profile" do
    profile = described_class.new(
      user: User.new(email: "candidate@example.com"),
      first_name: "Sophie",
      last_name: "van Dijk",
      email: "sophie@example.com",
      phone_number: "+31 6 12345678",
      city: "Amsterdam",
      desired_job_function: "Dental hygienist",
      preferred_regions: ["Amsterdam"],
      maximum_travel_time: 30,
      search_status: "Active",
      employment_types: ["Employed"],
      desired_gross_salary: 4200,
      years_of_experience: 6,
      available_working_days: ["Monday", "Tuesday"],
      available_from: Date.current,
      consent_accepted: true,
      completed_at: Time.current
    )

    expect(profile).to be_valid
  end

  it "requires big number only when big registered" do
    profile = described_class.new(
      user: User.new(email: "candidate@example.com"),
      first_name: "Eva",
      last_name: "Jansen",
      email: "eva@example.com",
      phone_number: "+31 6 87654321",
      city: "Utrecht",
      desired_job_function: "General dentist",
      preferred_regions: ["Utrecht"],
      maximum_travel_time: 45,
      search_status: "Active",
      employment_types: ["Self-employed"],
      desired_percentage: 45,
      big_registration_status: "BIG registered",
      years_of_experience: 10,
      available_working_days: ["Friday"],
      available_from: Date.current,
      consent_accepted: true,
      completed_at: Time.current
    )

    expect(profile).not_to be_valid
    expect(profile.errors[:big_number]).to include("can't be blank")
  end
end
