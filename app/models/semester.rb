# app/models/semester.rb
require 'csv'

class Semester < ApplicationRecord
  # --------------------------------------------------------
  # ASSOCIATIONS
  # --------------------------------------------------------
  has_one_attached :student_csv
  has_one_attached :git_csv
  has_one_attached :client_csv

  belongs_to :user
  has_many :sprints, inverse_of: :semester, dependent: :destroy
  has_many :teams, inverse_of: :semester, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :repositories, dependent: :nullify

  accepts_nested_attributes_for :sprints, allow_destroy: true, reject_if: :all_blank

  # --------------------------------------------------------
  # VALIDATIONS
  # --------------------------------------------------------
  validates :semester, presence: true, inclusion: { in: %w[Fall Spring Summer] }
  validates :semester, uniqueness: { scope: :year, message: "Semester and year combination already exists" }
  validates :year, presence: true

  # --------------------------------------------------------
  # CALLBACKS
  # --------------------------------------------------------
  after_create :create_default_sprints

  # --------------------------------------------------------
  # INSTANCE METHODS
  # --------------------------------------------------------

  # Display-friendly name (e.g. "Fall 2025")
  def name_for_select
    "#{semester} #{year}"
  end

  # --------------------------------------------------------
  # CLASS METHODS
  # --------------------------------------------------------

  # Determines the currently active semester based on date
  def self.current_active
    current_date = Date.current
    current_year = current_date.year

    spring_range = Date.new(current_year, 1, 1)..Date.new(current_year, 5, 31)
    summer_range = Date.new(current_year, 6, 1)..Date.new(current_year, 7, 31)
    fall_range   = Date.new(current_year, 8, 1)..Date.new(current_year, 12, 31)

    current_semester = case current_date
                       when spring_range then 'Spring'
                       when summer_range then 'Summer'
                       when fall_range   then 'Fall'
                       end

    where(semester: current_semester, year: current_year).first ||
      order(year: :desc, semester: :desc).first
  end

  # Debug helper for static CSVs (legacy testing)
  def self.debug_students
    filepath = Rails.root.join('lib', 'assets', 'Students_list.csv')
    students = CSV.read(filepath, headers: true).map { |row| { name: row['Name'], role: row['Role'] } }
    puts students.inspect
  end

  # --------------------------------------------------------
  # ROBUST STUDENT CSV IMPORTER
  # --------------------------------------------------------
  # Handles import of student roster CSVs. Automatically:
  # - Parses flexible headers (case-insensitive)
  # - Creates teams if missing
  # - Creates or updates students
  # - Links students to teams
#   def import_students_from_csv
#   return true unless student_csv.attached?

#   student_csv.open do |tempfile|
#     begin
#       csv = CSV.read(tempfile.path, headers: true)
#       headers = csv.headers.map { |h| h.to_s.strip }

#       # Flexible header matching
#       header_candidates = {
#         name: ["full name", "fullname", "name"],
#         email: ["email", "e-mail", "e mail"],
#         team: ["team", "group"],
#         github_username: ["github username", "github_username", "github"],
#         project_board: ["github project board link", "project board", "project_board"],
#         timesheet: ["timesheet link", "timesheet", "timesheet_url"],
#         client_notes: ["client meeting notes link", "client meeting notes", "client_notes"]
#       }

#       header_map = {}
#       header_candidates.each do |key, candidates|
#         found = headers.find { |h| candidates.include?(h.downcase) }
#         header_map[key] = found
#       end

#       if header_map[:name].nil? || header_map[:email].nil?
#         raise "CSV must include at least 'Full name' and 'Email' columns. Found: #{headers.join(', ')}"
#       end

#       ActiveRecord::Base.transaction do
#         csv.each_with_index do |row, i|
#           name  = row[header_map[:name]]&.strip
#           email = row[header_map[:email]]&.strip&.downcase
#           team_name = row[header_map[:team]]&.strip
#           github_username = row[header_map[:github_username]]&.strip
#           project_board   = row[header_map[:project_board]]&.strip
#           timesheet       = row[header_map[:timesheet]]&.strip
#           client_notes    = row[header_map[:client_notes]]&.strip

#           # ❌ Skip empty rows
#           next if name.blank? && email.blank?

#           # ❌ Validate required fields
#           if name.blank?
#             raise "Row #{i + 2}: Name is missing"
#           end

#           if email.blank? || !(email =~ URI::MailTo::EMAIL_REGEXP)
#             raise "Row #{i + 2}: Email is missing or invalid (#{email})"
#           end

#           # ❌ Optional URL validations
#           url_fields = {
#             "Project Board URL" => project_board,
#             "Timesheet URL" => timesheet,
#             "Client Notes URL" => client_notes
#           }

#           url_fields.each do |label, url|
#             if url.present? && !(url =~ /\Ahttps?:\/\/[\S]+\z/)
#               raise "Row #{i + 2}: #{label} is not a valid URL: #{url}"
#             end
#           end

#           # ✅ Create/find team
#           team = teams.find_or_create_by!(name: team_name) if team_name.present?

#           # ✅ Assign team-level URLs (if not already present)
#           if team
#             team.repo_url           = project_board   if project_board.present?
#             team.project_board_url  = project_board   if project_board.present?
#             team.timesheet_url      = timesheet       if timesheet.present?
#             team.client_notes_url   = client_notes    if client_notes.present?
#             team.save!              if team.changed?
#           end


#           # ✅ Create or update student
#           student = students.find_or_initialize_by(email: email)
#           student.assign_attributes(
#             name: name,
#             email: email,
#             github_username: github_username,
#             project_board_url: project_board,
#             timesheet_url: timesheet,
#             client_notes_url: client_notes,
#             semester: self
#           )
#           student.save!

#           # ✅ Link to team (if not already linked)
#           if team && !team.students.exists?(student.id)
#             team.students << student
#           end
#         end
#       end

#       true
#     rescue => e
#       Rails.logger.error("CSV import failed: #{e.class} - #{e.message}")
#       errors.add(:student_csv, "Import failed: #{e.message}")
#       false
#     end
#   end
# end

# def import_students_from_csv
#   return true unless student_csv.attached?

#   student_csv.open do |tempfile|
#     begin
#       csv = CSV.read(tempfile.path, headers: true)
#       headers = csv.headers.map { |h| h.to_s.strip }

#       # Flexible header matching
#       header_candidates = {
#         name: ["full name", "fullname", "name"],
#         email: ["email", "e-mail", "e mail"],
#         team: ["team", "group"],
#         github_username: ["github username", "github_username", "github"],
#         repo_url: ["repo url", "repository link", "repository", "repo"],
#         project_board: ["github project board link", "project board", "project_board"],
#         timesheet: ["timesheet link", "timesheet", "timesheet_url"],
#         client_notes: ["client meeting notes link", "client meeting notes", "client_notes"]
#       }

#       header_map = {}
#       header_candidates.each do |key, candidates|
#         found = headers.find { |h| candidates.include?(h.downcase) }
#         header_map[key] = found
#       end

#       # ✅ Must include name + email columns
#       if header_map[:name].nil? || header_map[:email].nil?
#         raise "CSV must include at least 'Full Name' and 'Email' columns. Found: #{headers.join(', ')}"
#       end

#       # ✅ Variables for remembering previous non-nil values
#       previous_team_name = nil
#       previous_repo_url = nil
#       previous_project_board = nil
#       previous_timesheet = nil
#       previous_client_notes = nil

#       ActiveRecord::Base.transaction do
#         csv.each_with_index do |row, i|
#           # --- Extract raw row data ---
#           name             = row[header_map[:name]]&.strip
#           email            = row[header_map[:email]]&.strip&.downcase
#           raw_team_name    = row[header_map[:team]]&.strip
#           raw_repo_url     = row[header_map[:repo_url]]&.strip
#           raw_project_board= row[header_map[:project_board]]&.strip
#           raw_timesheet    = row[header_map[:timesheet]]&.strip
#           raw_client_notes = row[header_map[:client_notes]]&.strip
#           github_username  = row[header_map[:github_username]]&.strip

#           # --- Detect new team and reset remembered values (BEFORE using them) ---
#           if raw_team_name.present? && raw_team_name != previous_team_name
#             previous_repo_url = nil
#             previous_project_board = nil
#             previous_timesheet = nil
#             previous_client_notes = nil
#           end

#           # --- Apply "remember previous non-nil" logic ---
#           team_name     = raw_team_name.presence     || previous_team_name
#           repo_url      = raw_repo_url.presence      || previous_repo_url
#           project_board = raw_project_board.presence || previous_project_board
#           timesheet     = raw_timesheet.presence     || previous_timesheet
#           client_notes  = raw_client_notes.presence  || previous_client_notes

#           # --- Update remembered values for next row ---
#           previous_team_name     = raw_team_name     if raw_team_name.present?
#           previous_repo_url      = raw_repo_url      if raw_repo_url.present?
#           previous_project_board = raw_project_board if raw_project_board.present?
#           previous_timesheet     = raw_timesheet     if raw_timesheet.present?
#           previous_client_notes  = raw_client_notes  if raw_client_notes.present?


#           # --- Skip or validate row ---
#           next if name.blank? && email.blank? # skip empty rows

#           if name.blank?
#             raise "Row #{i + 2}: Missing Full Name"
#           end
#           if email.blank? || !(email =~ URI::MailTo::EMAIL_REGEXP)
#             raise "Row #{i + 2}: Missing or invalid Email (#{email})"
#           end

#           # --- Validate URL formats ---
#           url_fields = {
#             "Repo URL" => repo_url,
#             "Project Board URL" => project_board,
#             "Timesheet URL" => timesheet,
#             "Client Notes URL" => client_notes
#           }
#           url_fields.each do |label, url|
#             if url.present? && !(url =~ /\Ahttps?:\/\/[\S]+\z/)
#               raise "Row #{i + 2}: #{label} is invalid: #{url}"
#             end
#           end

#           # --- Create/find team and assign team-level links ---
#           team = teams.find_or_create_by!(name: team_name) if team_name.present?
#           if team
#             team.repo_url           ||= repo_url
#             team.project_board_url  ||= project_board
#             team.timesheet_url      ||= timesheet
#             team.client_notes_url   ||= client_notes
#             team.save! if team.changed?
#           end

#           # --- Create or update student record ---
#           student = students.find_or_initialize_by(email: email)
#           student.assign_attributes(
#             name: name,
#             full_name: name,
#             email: email,
#             github_username: github_username,
#             project_board_url: project_board,
#             timesheet_url: timesheet,
#             client_notes_url: client_notes,
#             semester: self
#           )
#           student.save!

#           # --- Link student to team ---
#           if team && !team.students.exists?(student.id)
#             team.students << student
#           end
#         end
#       end

#       true
#     rescue => e
#       Rails.logger.error("CSV import failed: #{e.class} - #{e.message}")
#       errors.add(:student_csv, "Import failed: #{e.message}")
#       false
#     end
#   end
# end
# def import_students_from_csv (old version 12/7/2025)
#   return true unless student_csv.attached?

#   student_csv.open do |tempfile|
#     csv = CSV.read(tempfile.path, headers: true)
#     headers = csv.headers.map { |h| h.to_s.strip }

#     # Flexible header matching
#     header_candidates = {
#       name: ["full name", "fullname", "name"],
#       email: ["email", "e-mail", "e mail"],
#       team: ["team", "group"],
#       github_username: ["github username", "github_username", "github"],
#       repo_url: ["repo url", "repository link", "repository", "repo"],
#       project_board: ["github project board link", "project board", "project_board"],
#       timesheet: ["timesheet link", "timesheet", "timesheet_url"],
#       client_notes: ["client meeting notes link", "client meeting notes", "client_notes"]
#     }

#     header_map = {}
#     header_candidates.each do |key, candidates|
#       found = headers.find { |h| candidates.include?(h.downcase) }
#       header_map[key] = found
#     end

#     # ✅ Must include name + email columns
#     if header_map[:name].nil? || header_map[:email].nil?
#       errors.add(:student_csv, "Missing required columns: Full Name and Email")
#       return false
#     end

#     # ✅ Setup memory and counters
#     previous_team_name = nil
#     previous_repo_url = nil
#     previous_project_board = nil
#     previous_timesheet = nil
#     previous_client_notes = nil

#     row_errors = []
#     successful_count = 0
#     skipped_count = 0

#     csv.each_with_index do |row, i|
#       begin
#         # --- Extract raw row data ---
#         name             = row[header_map[:name]]&.strip
#         email            = row[header_map[:email]]&.strip&.downcase
#         raw_team_name    = row[header_map[:team]]&.strip
#         raw_repo_url     = row[header_map[:repo_url]]&.strip
#         raw_project_board= row[header_map[:project_board]]&.strip
#         raw_timesheet    = row[header_map[:timesheet]]&.strip
#         raw_client_notes = row[header_map[:client_notes]]&.strip
#         github_username  = row[header_map[:github_username]]&.strip

#         # --- Detect new team and reset remembered values (BEFORE using them) ---
#         if raw_team_name.present? && raw_team_name != previous_team_name
#           previous_repo_url = nil
#           previous_project_board = nil
#           previous_timesheet = nil
#           previous_client_notes = nil
#         end

#         # --- Apply "remember previous non-nil" logic ---
#         team_name     = raw_team_name.presence     || previous_team_name
#         repo_url      = raw_repo_url.presence      || previous_repo_url
#         project_board = raw_project_board.presence || previous_project_board
#         timesheet     = raw_timesheet.presence     || previous_timesheet
#         client_notes  = raw_client_notes.presence  || previous_client_notes

#         # --- Update remembered values for next row ---
#         previous_team_name     = raw_team_name     if raw_team_name.present?
#         previous_repo_url      = raw_repo_url      if raw_repo_url.present?
#         previous_project_board = raw_project_board if raw_project_board.present?
#         previous_timesheet     = raw_timesheet     if raw_timesheet.present?
#         previous_client_notes  = raw_client_notes  if raw_client_notes.present?

#         # --- Skip or validate row ---
#         next if name.blank? && email.blank? # skip empty rows

#         if name.blank?
#           row_errors << "Row #{i + 2}: Missing Full Name"
#           skipped_count += 1
#           next
#         end

#         if email.blank? || !(email =~ URI::MailTo::EMAIL_REGEXP)
#           row_errors << "Row #{i + 2}: Missing or invalid Email (#{email})"
#           skipped_count += 1
#           next
#         end

#         # --- Validate URL formats ---
#         url_fields = {
#           "Repo URL" => repo_url,
#           "Project Board URL" => project_board,
#           "Timesheet URL" => timesheet,
#           "Client Notes URL" => client_notes
#         }
#         url_fields.each do |label, url|
#           if url.present? && !(url =~ /\Ahttps?:\/\/[\S]+\z/)
#             row_errors << "Row #{i + 2}: #{label} is invalid: #{url}"
#             skipped_count += 1
#             next
#           end
#         end

#         # --- Create/find team and assign team-level links ---
#         team = teams.find_or_create_by!(name: team_name) if team_name.present?
#         if team
#           team.repo_url           ||= repo_url
#           team.project_board_url  ||= project_board
#           team.timesheet_url      ||= timesheet
#           team.client_notes_url   ||= client_notes
#           team.save! if team.changed?
#         end

#         # --- Create or update student record (Prevent duplicate creation) ---

#         existing_student = students.find_by(email: email)

#         if existing_student
#           # UPDATE instead of creating duplicate
#           existing_student.assign_attributes(
#             name: name,
#             full_name: name,
#             github_username: github_username,
#             project_board_url: project_board,
#             timesheet_url: timesheet,
#             client_notes_url: client_notes
#           )

#           if existing_student.changed?
#             existing_student.save!
#             successful_count += 1
#           else
#             # No changes → skip duplicate row
#             skipped_count += 1
#           end

#           student = existing_student
#         else
#           # CREATE new student
#           student = students.create!(
#             name: name,
#             full_name: name,
#             email: email,
#             github_username: github_username,
#             project_board_url: project_board,
#             timesheet_url: timesheet,
#             client_notes_url: client_notes,
#             semester: self
#           )
#           successful_count += 1
#         end


#         # --- Link student to team ---
#         if team && !team.students.exists?(student.id)
#           team.students << student
#         end

#       rescue => row_error
#         Rails.logger.error("Row #{i + 2} failed: #{row_error.message}")
#         row_errors << "Row #{i + 2}: #{row_error.message}"
#         skipped_count += 1
#         next
#       end
#     end

#     # # ✅ Final summary message
#     # if row_errors.any?
#     #   errors.add(:student_csv, "Import completed with errors. #{successful_count} rows imported, #{skipped_count} skipped. Details: #{row_errors.join('; ')}")
#     # else
#     #   errors.add(:student_csv, "#{successful_count} students imported successfully.")
#     # end
#     # Final summary message

#     if row_errors.any?
#       @import_summary = "Import completed with errors. #{successful_count} rows imported, #{skipped_count} skipped.<br>Details:<br>#{row_errors.join('<br>')}"
#       return false
#     else
#       @import_summary = "Semester created successfully and students imported."
#       return true
#     end

#     true
#   rescue => e
#     Rails.logger.error("CSV import failed: #{e.class} - #{e.message}")
#     errors.add(:student_csv, "Import failed: #{e.message}")
#     false
#   end
# end

def import_students_from_csv
  return true unless student_csv.attached?

  student_csv.open do |tempfile|
    csv = CSV.read(tempfile.path, headers: true)
    headers = csv.headers.map { |h| h.to_s.strip }

    # Flexible header matching
    header_candidates = {
      name: ["full name", "fullname", "name"],
      email: ["email", "e-mail", "e mail"],
      team: ["team", "group"],
      github_username: ["github username", "github_username", "github"],
      repo_url: ["repo url", "repository link", "repository", "repo"],
      project_board: ["github project board link", "project board", "project_board"],
      timesheet: ["timesheet link", "timesheet", "timesheet_url"],
      client_notes: ["client meeting notes link", "client meeting notes", "client_notes"]
    }

    header_map = {}
    header_candidates.each do |key, candidates|
      found = headers.find { |h| candidates.include?(h.downcase) }
      header_map[key] = found
    end

    # Must include Name + Email
    if header_map[:name].nil? || header_map[:email].nil?
      errors.add(:student_csv, "Missing required columns: Full Name and Email")
      return false
    end

    # Memory for "remember previous non-nil"
    previous_team_name = nil
    previous_repo_url = nil
    previous_project_board = nil
    previous_timesheet = nil
    previous_client_notes = nil

    # Counters
    row_errors = []
    created_count = 0
    updated_count = 0
    skipped_count = 0

    csv.each_with_index do |row, i|
      begin
        # Extract row fields
        name             = row[header_map[:name]]&.strip
        email            = row[header_map[:email]]&.strip&.downcase
        raw_team_name    = row[header_map[:team]]&.strip
        raw_repo_url     = row[header_map[:repo_url]]&.strip
        raw_project_board= row[header_map[:project_board]]&.strip
        raw_timesheet    = row[header_map[:timesheet]]&.strip
        raw_client_notes = row[header_map[:client_notes]]&.strip
        github_username  = row[header_map[:github_username]]&.strip

        # Reset remembered values when team changes
        if raw_team_name.present? && raw_team_name != previous_team_name
          previous_repo_url = nil
          previous_project_board = nil
          previous_timesheet = nil
          previous_client_notes = nil
        end

        # Fill forward non-nil values
        team_name     = raw_team_name.presence     || previous_team_name
        repo_url      = raw_repo_url.presence      || previous_repo_url
        project_board = raw_project_board.presence || previous_project_board
        timesheet     = raw_timesheet.presence     || previous_timesheet
        client_notes  = raw_client_notes.presence  || previous_client_notes

        # Update memory trackers
        previous_team_name     = raw_team_name     if raw_team_name.present?
        previous_repo_url      = raw_repo_url      if raw_repo_url.present?
        previous_project_board = raw_project_board if raw_project_board.present?
        previous_timesheet     = raw_timesheet     if raw_timesheet.present?
        previous_client_notes  = raw_client_notes  if raw_client_notes.present?

        # Skip empty rows
        next if name.blank? && email.blank?

        # Required field validation
        if name.blank?
          row_errors << "Row #{i + 2}: Missing Full Name"
          skipped_count += 1
          next
        end

        if email.blank? || !(email =~ URI::MailTo::EMAIL_REGEXP)
          row_errors << "Row #{i + 2}: Missing or invalid Email (#{email})"
          skipped_count += 1
          next
        end

        # URL validation
        url_fields = {
          "Repo URL" => repo_url,
          "Project Board URL" => project_board,
          "Timesheet URL" => timesheet,
          "Client Notes URL" => client_notes
        }
        url_fields.each do |label, url|
          if url.present? && !(url =~ /\Ahttps?:\/\/[\S]+\z/)
            row_errors << "Row #{i + 2}: #{label} is invalid: #{url}"
            skipped_count += 1
            next
          end
        end

        # Create/find team
        team = teams.find_or_create_by!(name: team_name) if team_name.present?
        if team
          team.repo_url           ||= repo_url
          team.project_board_url  ||= project_board
          team.timesheet_url      ||= timesheet
          team.client_notes_url   ||= client_notes
          team.save! if team.changed?
        end

        # --- Prevent duplicate student creation ---
        existing_student = students.find_by(email: email)

        if existing_student
          # UPDATE instead of creating duplicate
          existing_student.assign_attributes(
            name: name,
            full_name: name,
            github_username: github_username,
            project_board_url: project_board,
            timesheet_url: timesheet,
            client_notes_url: client_notes
          )

          if existing_student.changed?
            existing_student.save!
            updated_count += 1
          else
            skipped_count += 1
          end

          student = existing_student
        else
          # CREATE new student
          student = students.create!(
            name: name,
            full_name: name,
            email: email,
            github_username: github_username,
            project_board_url: project_board,
            timesheet_url: timesheet,
            client_notes_url: client_notes,
            semester: self
          )
          created_count += 1
        end

        # Link student to team (no duplicates)
        if team && !team.students.exists?(student.id)
          team.students << student
        end

      rescue => row_error
        Rails.logger.error("Row #{i + 2} failed: #{row_error.message}")
        row_errors << "Row #{i + 2}: #{row_error.message}"
        skipped_count += 1
        next
      end
    end

    # Final Summary Message
    if row_errors.any?
      @import_summary =
        "Import completed with errors.<br>" \
        "#{created_count} created, #{updated_count} updated, #{skipped_count} skipped.<br>" \
        "Details:<br>#{row_errors.join('<br>')}"
      return false
    else
      @import_summary =
        "Semester created successfully and students imported." \
        "#{created_count} created, #{updated_count} updated, #{skipped_count} skipped."
      return true
    end

  rescue => e
    Rails.logger.error("CSV import failed: #{e.class} - #{e.message}")
    errors.add(:student_csv, "Import failed: #{e.message}")
    return false
  end
end





  # --------------------------------------------------------
  # PRIVATE METHODS
  # --------------------------------------------------------
  private

  # Automatically create 4 default sprints after semester creation
  def create_default_sprints
    start_date = Date.new(self.year.to_i, 1, 30)

    4.times do |i|
      end_date = start_date + 28.days

      self.sprints.create!(
        name: "Sprint #{i + 1}",
        start_date: start_date,
        end_date: end_date
      )

      start_date = end_date + 1.day
    end
  end
end
