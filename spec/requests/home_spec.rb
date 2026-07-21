require "rails_helper"

RSpec.describe "Home", type: :request do
  it "shows the home page with an onboarding link" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Candidate onboarding")
    expect(response.body).to include(new_candidate_onboarding_path)
  end
end
