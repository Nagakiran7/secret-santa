namespace :secret_santa do
  desc "Generate Secret Santa assignments"

  task generate: :environment do
    input_file = Rails.root.join("input/Employee-List.csv")
    last_year_file = Rails.root.join("input/last_year.csv")
    output_dir = Rails.root.join("output")
    output_file = output_dir.join("secret_santa_output.csv")

    puts "🔄 Loading employees..."

    employees = SecretSantaService.load_employees(input_file)
    last_year = SecretSantaService.load_last_year(last_year_file)

    puts "🎯 Generating assignments..."

    service = SecretSantaService.new(employees, last_year)
    assignments = service.generate!

    Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

    SecretSantaService.write_output(assignments, output_file)

    puts "✅ Secret Santa assignments generated!"
    puts "📁 Output: #{output_file}"
  end
end