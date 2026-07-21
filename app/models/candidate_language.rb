class CandidateLanguage < ApplicationRecord
  belongs_to :candidate_profile
  belongs_to :language

  LEVELS = ["Native", "Fluent", "C1", "B2", "B1", "Basic"].freeze
end
