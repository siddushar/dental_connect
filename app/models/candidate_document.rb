class CandidateDocument < ApplicationRecord
  belongs_to :candidate_profile

  has_one_attached :file

  STATUSES = %w[pending processing completed failed].freeze
  MAX_FILE_SIZE = ENV.fetch("CV_MAX_FILE_SIZE_MB", 25).to_i.megabytes

  ALLOWED_CONTENT_TYPES = [
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ].freeze

  validates :document_type, presence: true
  validates :parsing_status, inclusion: { in: STATUSES }
  validate :acceptable_file

  before_validation :copy_file_metadata

  private
  
  def acceptable_file
    return unless file.attached?

    errors.add(:file, "must be PDF, DOC, or DOCX") unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
    errors.add(:file, "must be smaller than #{MAX_FILE_SIZE / 1.megabyte} MB") if file.blob.byte_size > MAX_FILE_SIZE
  end

  def copy_file_metadata
    self.document_type ||= "cv"
    self.parsing_status ||= "pending"
    return unless file.attached?

    self.original_filename = file.filename.to_s
    self.content_type = file.content_type
    self.file_size = file.blob.byte_size
  end
end
