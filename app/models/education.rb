class Education < ApplicationRecord
  belongs_to :candidate_profile

  LEVELS = ["MBO", "HBO", "Bachelor", "Master", "Doctor", "Course"].freeze
end
