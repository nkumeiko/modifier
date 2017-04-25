module FixturesHelper
  def read_fixture(name)
    YAML.load_file(File.expand_path("spec/fixtures/#{name}.yml", ROOT))
  end

  def write_data_to_input_file(content, input_filename)
    FileUtils.rm_rf "#{ ENV['HOME'] }/workspace"
    FileUtils.mkdir_p "#{ ENV['HOME'] }/workspace"

    CSV.open("#{ ENV['HOME'] }/workspace/#{input_filename}", "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
      csv << content.first.keys
      content.each do |row|
        csv << row
      end
    end
  end
end

RSpec.configure do |config|
  config.include FixturesHelper
end
