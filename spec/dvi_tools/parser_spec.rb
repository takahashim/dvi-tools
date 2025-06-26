# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DviTools::Parser do
  describe '#initialize' do
    it 'creates a parser instance with file path' do
      parser = described_class.new('/path/to/file.dvi')
      expect(parser).to be_a(described_class)
    end
  end

  describe '#parse' do
    context 'with non-existent file' do
      it 'raises ParseError' do
        parser = described_class.new('/non/existent/file.dvi')
        expect { parser.parse }.to raise_error(DviTools::ParseError)
      end
    end

    context 'with invalid DVI file' do
      let(:invalid_file) { 'spec/fixtures/invalid.dvi' }

      before do
        FileUtils.mkdir_p('spec/fixtures')
        File.write(invalid_file, 'invalid content')
      end

      after do
        FileUtils.rm_f(invalid_file)
      end

      it 'raises ParseError for invalid format' do
        parser = described_class.new(invalid_file)
        expect { parser.parse }.to raise_error(DviTools::ParseError, /Invalid DVI file/)
      end
    end
  end

  describe 'byte reading methods' do
    let(:parser) { described_class.new('/dummy/path') }

    it 'handles invalid data gracefully' do
      # Test that parser raises appropriate errors for invalid data
      expect { parser.parse }.to raise_error(DviTools::ParseError)
    end
  end
end
