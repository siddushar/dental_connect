class ParseCandidateCvJob < ApplicationJob
  queue_as :default

  def perform(document)
    document.update!(parsing_status: "processing")
    CvParser.new(document).apply
    document.update!(parsing_status: "completed", parsed_at: Time.current, parsing_error: nil)
  rescue StandardError => e
    document.update!(parsing_status: "failed", parsing_error: e.message)
  end
end
