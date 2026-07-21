# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


[
  "Dutch",
  "English",
  "German",
  "French",
  "Spanish"
].each do |name|
  Language.find_or_create_by!(name: name)
end

skills = {
  "Dentist" => ["Endodontics", "Restorative dentistry", "Pediatric dentistry", "Surgery", "Aligners"],
  "Dental hygienist" => ["Periodontology", "Prevention", "Scaling", "Patient education"],
  "Dental assistant" => ["Chairside assistance", "Sterilization", "Orthodontics", "Prevention"],
  "Front-office" => ["Planning", "Phone handling", "Invoicing", "Patient communication"],
  "Practice manager" => ["Team management", "Scheduling", "HR", "Practice operations"],
  "Dental technician" => ["Prosthetics", "CAD/CAM", "Crown and bridge work"]
}

skills.each do |function_group, names|
  names.each do |name|
    Skill.find_or_create_by!(name: name, function_group: function_group)
  end
end