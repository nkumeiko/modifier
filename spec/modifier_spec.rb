require 'spec_helper'

RSpec.describe 'modifier.rb' do
  subject(:execute_modifier) do
    ARGV[0] = 'project_2012-07-27_2012-10-10_performancedata'
    load File.expand_path('modifier.rb', ROOT)
  end

  context 'with simple one-line input' do
    let!(:content) { read_fixture('sample_1') }
    let(:input_filename) { 'project_2012-07-27_2012-10-10_performancedata.txt' }

    it 'processes sample_1 without exceptions' do
      FakeFS do
        write_data_to_input_file(content, input_filename)
        execute_modifier
      end
    end
  end

  context 'with more complex input' do
    let!(:content) { read_fixture('sample_2') }
    let(:input_filename) { 'project_2012-07-27_2012-10-10_performancedata.txt' }
    let(:output_filename) { 'project_2012-07-27_2012-10-10_performancedata_0.txt' }

    it 'processes sample_2 without exceptions' do
      FakeFS do
        write_data_to_input_file(content, input_filename)
        execute_modifier
      end
    end
  end
end
