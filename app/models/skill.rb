class Skill < ApplicationRecord
	has_many :candidate_skills, dependent: :destroy
  has_many :candidate_profiles, through: :candidate_skills

  validates :name, :function_group, presence: true
end
