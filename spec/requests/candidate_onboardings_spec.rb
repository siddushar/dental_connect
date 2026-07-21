require "rails_helper"

RSpec.describe "Candidate onboardings", type: :request do
  it "shows the cv upload step" do
    get new_candidate_onboarding_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Upload your CV")
  end

  it "shows the profile review step" do
    get edit_candidate_onboarding_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Review and complete your profile")
  end

  it "shows the submitted profile summary" do
    get candidate_onboarding_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Candidate profile saved")
  end

  it "starts manual onboarding with a blank profile" do
    user = User.create!(email: "candidate@example.com", name: "Demo Candidate")
    user.create_candidate_profile!(
      first_name: "Existing",
      last_name: "Candidate",
      email: "existing@example.com"
    )

    post manual_candidate_onboarding_path

    expect(response).to redirect_to(edit_candidate_onboarding_path)
    expect(user.reload.candidate_profile).to be_nil
  end
end
