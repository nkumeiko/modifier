require 'spec_helper'

RSpec.describe 'modifier.rb' do
  context 'with simple one-line input' do
    let!(:content) { read_fixture('sample_1') }
    let(:default_input_filename) { 'project_2012-07-27_2012-10-10_performancedata.txt' }

    subject(:execute_modifier) do
      load File.expand_path('modifier.rb', ROOT)
    end

    it 'processes sample_1' do
      FakeFS do
        write_data_to_input_file(content, default_input_filename)
        execute_modifier
      end
    end
  end
end
