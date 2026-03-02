require 'csv'

class SecretSantaService
  MAX_ATTEMPTS = 1000

  def initialize(employees, last_year_map = {})
    @employees = employees
    @last_year_map = last_year_map || {}
  end

  # -------- main assignment --------
  def generate!
    MAX_ATTEMPTS.times do
      receivers = @employees.shuffle
      assignments = []
      valid = true

      @employees.zip(receivers).each do |giver, receiver|
        # Rule 1: no self assignment
        if giver[:email] == receiver[:email]
          valid = false
          break
        end

        # Rule 2: avoid last year
        if @last_year_map[giver[:email]] == receiver[:email]
          valid = false
          break
        end

        assignments << [giver, receiver]
      end

      return assignments if valid
    end

    raise "Unable to generate valid Secret Santa assignment"
  end

  # -------- file helpers --------

  def self.load_employees(file_path)
    raise "Employee file not found" unless File.exist?(file_path)

    CSV.read(file_path, headers: true).map do |row|
      {
        name: row["Employee_Name"],
        email: row["Employee_EmailID"]
      }
    end
  end

  def self.load_last_year(file_path)
    return {} unless File.exist?(file_path)

    CSV.read(file_path, headers: true).to_h do |row|
      [row["Employee_EmailID"], row["Secret_Child_EmailID"]]
    end
  end

  def self.write_output(assignments, output_file)
    CSV.open(output_file, "w") do |csv|
      csv << [
        "Employee_Name",
        "Employee_EmailID",
        "Secret_Child_Name",
        "Secret_Child_EmailID"
      ]

      assignments.each do |giver, receiver|
        csv << [
          giver[:name],
          giver[:email],
          receiver[:name],
          receiver[:email]
        ]
      end
    end
  end
end