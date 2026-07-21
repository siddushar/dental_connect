require "rails_helper"
require "zip"

RSpec.describe CvParser, type: :model do
  it "extracts profile details from docx files" do
    Language.find_or_create_by!(name: "English")
    Skill.find_or_create_by!(name: "Scaling", function_group: "Dental hygienist")

    profile = User.create!(email: "candidate@example.com").create_candidate_profile!
    document = attach_cv(profile)

    described_class.new(document).apply

    profile.reload
    expect(profile.first_name).to eq("Sophie")
    expect(profile.last_name).to eq("van Dijk")
    expect(profile.email).to eq("sophie@example.com")
    expect(profile.phone_number).to eq("+31 6 12345678")
    expect(profile.desired_job_function).to eq("Dental hygienist")
    expect(profile.years_of_experience).to eq(6)
    expect(profile.skills.map(&:name)).to include("Scaling")
  end

  it "overwrites existing profile fields on repeated cv upload" do
    Skill.find_or_create_by!(name: "Scaling", function_group: "Dental hygienist")

    profile = User.create!(email: "candidate@example.com").create_candidate_profile!(
      first_name: "Manual",
      email: "manual@example.com",
      phone_number: "+91 9876543210",
      city: "Bangalore",
      desired_job_function: "Dental assistant",
      years_of_experience: 3
    )
    document = attach_cv(profile)

    described_class.new(document).apply

    profile.reload
    expect(profile.first_name).to eq("Sophie")
    expect(profile.email).to eq("sophie@example.com")
    expect(profile.phone_number).to eq("+31 6 12345678")
    expect(profile.desired_job_function).to eq("Dental hygienist")
    expect(profile.years_of_experience).to eq(6)
    expect(profile.last_name).to eq("van Dijk")
    expect(profile.skills.map(&:name)).to include("Scaling")
  end

  def attach_cv(profile)
    document = profile.candidate_documents.create!(document_type: "cv", parsing_status: "pending")
    document.file.attach(
      io: StringIO.new(docx_bytes),
      filename: "sample_cv.docx",
      content_type: CandidateDocument::ALLOWED_CONTENT_TYPES.last
    )
    document
  end

  def docx_bytes
    buffer = Zip::OutputStream.write_buffer do |zip|
      zip.put_next_entry("[Content_Types].xml")
      zip.write(%(<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"></Types>))

      zip.put_next_entry("word/document.xml")
      zip.write <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:r><w:t>Sophie van Dijk</w:t></w:r></w:p>
            <w:p><w:r><w:t>Email: sophie@example.com</w:t></w:r></w:p>
            <w:p><w:r><w:t>Phone: +31 6 12345678</w:t></w:r></w:p>
            <w:p><w:r><w:t>Dental hygienist with 6 years of dental experience</w:t></w:r></w:p>
            <w:p><w:r><w:t>Skills: Scaling</w:t></w:r></w:p>
            <w:p><w:r><w:t>English fluent</w:t></w:r></w:p>
          </w:body>
        </w:document>
      XML
    end

    buffer.rewind
    buffer.string
  end
end
