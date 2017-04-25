class Modifier
  module Utils
    def self.latest(name)
      files = Dir["#{ ENV["HOME"] }/workspace/*#{name}*.txt"]

      files.sort_by! do |file|
        last_date = /\d+-\d+-\d+_[[:alpha:]]+\.txt$/.match file
        last_date = last_date.to_s.match /\d+-\d+-\d+/

        date = DateTime.parse(last_date.to_s)
        date
      end

      throw RuntimeError if files.empty?

      files.last
    end
  end
end
