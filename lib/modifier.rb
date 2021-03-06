require 'csv'
require 'date'
require_relative 'combiner'
require_relative 'german/float'
require_relative 'german/string'
require_relative 'modifier/utils'

class Modifier

  KEYWORD_UNIQUE_ID = 'Keyword Unique ID'
  LAST_VALUE_WINS = ['Account ID', 'Account Name', 'Campaign', 'Ad Group', 'Keyword', 'Keyword Type', 'Subid', 'Paused', 'Max CPC', 'Keyword Unique ID', 'ACCOUNT', 'CAMPAIGN', 'BRAND', 'BRAND+CATEGORY', 'ADGROUP', 'KEYWORD']
  LAST_REAL_VALUE_WINS = ['Last Avg CPC', 'Last Avg Pos']
  INT_VALUES = ['Clicks', 'Impressions', 'ACCOUNT - Clicks', 'CAMPAIGN - Clicks', 'BRAND - Clicks', 'BRAND+CATEGORY - Clicks', 'ADGROUP - Clicks', 'KEYWORD - Clicks']
  FLOAT_VALUES = ['Avg CPC', 'CTR', 'Est EPC', 'newBid', 'Costs', 'Avg Pos']

  VALUES_INFLUENCED_BY_CANCELLATION_FACTOR = ['number of commissions']
  VALUES_INFLUENCED_BY_CANCELLATION_AND_SALEAMOUNT_FACTORS = ['Commission Value', 'ACCOUNT - Commission Value', 'CAMPAIGN - Commission Value', 'BRAND - Commission Value', 'BRAND+CATEGORY - Commission Value', 'ADGROUP - Commission Value', 'KEYWORD - Commission Value']

  LINES_PER_FILE = 120000

  def initialize(saleamount_factor, cancellation_factor)
    @saleamount_factor = saleamount_factor
    @cancellation_factor = cancellation_factor
  end

  # TODO: Revise the logic for multiple input files or get rid of redundant combiner
  def modify(output_filename, input_filename)
    input_filename = sort_by_clicks(input_filename)
    input_enumerator = lazy_read(input_filename)

    combiner = Combiner.new do |value|
      value[KEYWORD_UNIQUE_ID]
    end.combine(input_enumerator)

    merger_enumerator = merge_combined_rows(combiner)

    write2files(output_filename.gsub('.txt', ''), merger_enumerator)
  end

  private

  def merge_combined_rows(enumerator)
    Enumerator.new do |yielder|
      loop do
        begin
          yielder.yield(combine_values(enumerator.next))
        rescue StopIteration
          break
        end
      end
    end
  end

  def sort_by_clicks(file)
    output = "#{file}.sorted"
    content_as_table = parse(file)
    headers = content_as_table.headers
    index_of_key = headers.index('Clicks')
    content = content_as_table.sort_by { |a| -a[index_of_key].to_i }
    write(content, headers, output)
    return output
  end

  def write2files(base_filename, enumerator)
    done = false
    file_index = 0
    until done do
      CSV.open(base_filename + "_#{file_index}.txt", "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
        headers_written = false
        line_count = 0
        while line_count < LINES_PER_FILE
          begin
            merged = enumerator.next
            if !headers_written
              csv << merged.keys
              headers_written = true
              line_count +=1
            end
            csv << merged
            line_count += 1
          rescue StopIteration
            done = true
            break
          end
        end
        file_index += 1
      end
    end
  end

  def combine(merged)
    result = []
    merged.each do |_, hash|
      result << combine_values(hash)
    end
    result
  end

  def combine_values(hash)
    LAST_VALUE_WINS.each do |key|
      hash[key] = hash[key].last
    end
    LAST_REAL_VALUE_WINS.each do |key|
      hash[key] = hash[key].select { |v| !(v.nil? || v == 0 || v == '0' || v == '') }.last
    end
    INT_VALUES.each do |key|
      hash[key] = hash[key][0].to_s
    end
    FLOAT_VALUES.each do |key|
      hash[key] = hash[key][0].from_german_to_f.to_german_s
    end
    VALUES_INFLUENCED_BY_CANCELLATION_FACTOR.each do |key|
      hash[key] = (@cancellation_factor * hash[key][0].from_german_to_f).to_german_s
    end
    VALUES_INFLUENCED_BY_CANCELLATION_AND_SALEAMOUNT_FACTORS.each do |key|
      hash[key] = (@cancellation_factor * @saleamount_factor * hash[key][0].from_german_to_f).to_german_s
    end
    hash
  end

  def combine_hashes(list_of_rows)
    keys = []
    list_of_rows.each do |row|
      next if row.nil?
      row.headers.each do |key|
        keys << key
      end
    end
    result = {}
    keys.each do |key|
      result[key] = []
      list_of_rows.each do |row|
        result[key] << (row.nil? ? nil : row[key])
      end
    end
    result
  end

  DEFAULT_CSV_OPTIONS = { :col_sep => "\t", :headers => :first_row }

  def parse(file)
    CSV.read(file, DEFAULT_CSV_OPTIONS)
  end

  def lazy_read(file)
    Enumerator.new do |yielder|
      CSV.foreach(file, DEFAULT_CSV_OPTIONS) do |row|
        yielder.yield(row)
      end
    end
  end

  def write(content, headers, output)
    CSV.open(output, "wb", DEFAULT_CSV_OPTIONS.merge(:row_sep => "\r\n")) do |csv|
      csv << headers
      content.each do |row|
        csv << row
      end
    end
  end
end
