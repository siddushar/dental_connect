class CvParser
  require "stringio"
  require "zip"
  require "nokogiri"

  EMAIL_PATTERN = /[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}/i
  PHONE_PATTERN = /(?:\+|00)?\d[\d\s().-]{7,}\d/
  DOCX_CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document".freeze

  def initialize(candidate_document)
    @candidate_document = candidate_document
    @profile = candidate_document.candidate_profile
  end

  def apply
    text = extract_text
    return if text.blank?

    @profile.assign_attributes(parsed_profile_attributes(text).compact_blank)
    add_languages(text)
    add_skills(text)
    add_simple_education(text)
    add_simple_work_experience(text)
    @profile.save!(validate: false)
  end

  private

  def extract_text
    file = @candidate_document.file
    return "" unless file.attached?

    bytes = file.download
    bytes = bytes.read if bytes.respond_to?(:read)
    bytes = bytes.to_s

    if docx_file?(file)
      extract_docx_text(bytes)
    else
      extract_readable_text(bytes)
    end
  end

  def docx_file?(file)
    file.content_type == DOCX_CONTENT_TYPE || file.filename.extension_without_delimiter.to_s.downcase == "docx"
  end

  def extract_docx_text(bytes)
    text = +""

    Zip::File.open_buffer(StringIO.new(bytes)) do |zip|
      text = zip.entries.select { |entry| docx_text_entry?(entry.name) }.flat_map do |entry|
        xml_text(entry.get_input_stream.read)
      end.join("\n")
    end

    normalize_extracted_text(text)
  rescue Zip::Error
    extract_readable_text(bytes)
  end

  def docx_text_entry?(name)
    name == "word/document.xml" ||
      name.match?(%r{\Aword/header\d*\.xml\z}) ||
      name.match?(%r{\Aword/footer\d*\.xml\z})
  end

  def xml_text(xml)
    document = Nokogiri::XML(xml)
    document.remove_namespaces!
    document.xpath("//t").map(&:text)
  end

  def extract_readable_text(bytes)
    normalize_extracted_text(
      bytes.to_s
           .force_encoding("UTF-8")
           .scrub
           .scan(/[[:print:]\n\r\t]{3,}/)
           .join(" ")
    )
  end

  def normalize_extracted_text(text)
    text.to_s
        .gsub(/\s*@\s*/, "@")
        .gsub(/(?<=\w)\s*\.\s*(?=\w)/, ".")
        .gsub(/[ \t]+/, " ")
  end

  def parsed_profile_attributes(text)
    {
      email: text[EMAIL_PATTERN],
      phone_number: text[PHONE_PATTERN],
      first_name: name_parts(text).first,
      last_name: name_parts(text).last,
      country: country_from(text),
      desired_job_function: job_function_from(text),
      big_number: text[/BIG(?:\s|:|-)*(number|nummer)?(?:\s|:|-)*(\d{6,})/i, 2],
      big_registration_status: text.match?(/BIG/i) ? "BIG registered" : nil,
      years_of_experience: text[/(\d+)\+?\s+(years|jaar)\s+(of\s+)?(dental\s+)?experience/i, 1],
      professional_summary: summary_from(text)
    }
  end

  def name_parts(text)
    first_line = text.lines.map(&:strip).reject(&:blank?).first.to_s
    return [] if first_line.match?(EMAIL_PATTERN) || first_line.length > 60

    parts = first_line.split(/\s+/)
    [parts.first, parts[1..]&.join(" ")]
  end

  def country_from(text)
    return "Netherlands" if text.match?(/netherlands|nederland/i)

    nil
  end

  def job_function_from(text)
    CandidateProfile::JOB_FUNCTIONS.find { |function| text.match?(/#{Regexp.escape(function)}/i) } ||
      CandidateProfile::JOB_FUNCTIONS.find { |function| text.downcase.include?(function.split.first.downcase) }
  end

  def add_languages(text)
    Language.find_each do |language|
      next unless text.match?(/\b#{Regexp.escape(language.name)}\b/i)
      next if @profile.candidate_languages.any? { |candidate_language| candidate_language.language_id == language.id }

      @profile.candidate_languages.build(language: language, level: level_near(text, language.name), source: "cv")
    end
  end

  def add_skills(text)
    Skill.find_each do |skill|
      next unless text.match?(/\b#{Regexp.escape(skill.name)}\b/i)

      @profile.skills << skill unless @profile.skills.include?(skill)
    end
  end

  def add_simple_education(text)
    return if @profile.educations.any?

    line = text.lines.find { |entry| entry.match?(/university|hogeschool|mbo|hbo|bachelor|master|course|opleiding|education/i) }
    @profile.educations.build(study: line.to_s.strip.truncate(120)) if line.present?
  end

  def add_simple_work_experience(text)
    return if @profile.work_experiences.any?

    line = text.lines.find { |entry| entry.match?(/dentist|hygienist|assistant|receptionist|manager|technician/i) }
    @profile.work_experiences.build(job_title: line.to_s.strip.truncate(80), company_name: "Please check") if line.present?
  end

  def level_near(text, language)
    match = text[/#{Regexp.escape(language)}.{0,30}(native|fluent|c1|b2|b1|basic)/i, 1]
    match&.capitalize
  end

  def summary_from(text)
    lines = text.lines.map(&:strip).reject(&:blank?)
    lines.find { |line| line.length.between?(80, 300) }&.truncate(400)
  end
end
