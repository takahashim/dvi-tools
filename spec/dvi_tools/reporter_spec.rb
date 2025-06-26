# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DviTools::Reporter do
  let(:sample_diff_result) do
    {
      layout: {
        page_count_diff: {
          file1: 1,
          file2: 1,
          difference: 0,
          changed: false
        },
        position_differences: {
          total_differences: 2,
          differences: [
            {
              type: :moved,
              from: { x: 10, y: 20, char: 65 },
              to: { x: 15, y: 20, char: 65 },
              index: 5,
              x_diff: 5,
              y_diff: 0
            },
            {
              type: :added,
              position: { x: 30, y: 40, char: 66 },
              index: 10
            }
          ]
        },
        dimension_differences: {
          x_range: {
            file1: { min: 0, max: 100 },
            file2: { min: 0, max: 120 },
            min_diff: 0,
            max_diff: 20
          },
          y_range: {
            file1: { min: 0, max: 50 },
            file2: { min: 0, max: 50 },
            min_diff: 0,
            max_diff: 0
          }
        }
      },
      content: {
        character_count_diff: {
          file1: 100,
          file2: 105,
          difference: 5,
          changed: true
        },
        special_commands_diff: {
          file1_count: 2,
          file2_count: 3,
          added: ['new_command'],
          removed: [],
          changed: true
        },
        rules_diff: {
          file1_count: 1,
          file2_count: 1,
          added: [],
          removed: [],
          changed: false
        },
        text_differences: {
          pages_with_differences: 1,
          differences: [
            {
              page: 0,
              file1_chars: 50,
              file2_chars: 55,
              changed: true
            }
          ]
        }
      },
      fonts: {
        font_usage_diff: {
          file1_font_count: 2,
          file2_font_count: 3,
          common_fonts: 2,
          different: true
        },
        added_fonts: [
          {
            font_num: 2,
            usage_count: 5,
            pages: [1]
          }
        ],
        removed_fonts: [],
        changed_usage: [
          {
            font_num: 0,
            file1_usage: 10,
            file2_usage: 15,
            usage_diff: 5
          }
        ]
      }
    }
  end

  let(:reporter) { described_class.new(sample_diff_result) }

  describe '#generate_report' do
    it 'generates a comprehensive report' do
      report = reporter.generate_report
      expect(report).to include('DVI Files Comparison Report')
      expect(report).to include('Layout Comparison:')
      expect(report).to include('Content Comparison:')
      expect(report).to include('Font Comparison:')
      expect(report).to include('Summary:')
    end

    it 'includes layout differences' do
      report = reporter.generate_report
      expect(report).to include('Position differences: 2')
    end

    it 'includes content differences' do
      report = reporter.generate_report
      expect(report).to include('Character count changed: 100 → 105 (+5)')
    end

    it 'includes font differences' do
      report = reporter.generate_report
      expect(report).to include('Font usage changed: 2 → 3 fonts')
    end
  end

  describe '#generate_summary' do
    it 'provides a summary of differences' do
      summary = reporter.generate_summary
      expect(summary).to include('Summary:')
      expect(summary).to include('Total differences detected:')
      expect(summary).to include('Files have differences.')
    end

    it 'calculates total differences correctly' do
      summary = reporter.generate_summary
      # Layout: 2, Content: 5, Fonts: 2 (1 added + 1 changed usage)
      expect(summary).to include('Total differences detected: 9')
    end
  end

  describe 'with detailed option' do
    let(:detailed_reporter) { described_class.new(sample_diff_result, detailed: true) }

    it 'includes detailed position differences' do
      report = detailed_reporter.generate_report
      expect(report).to include('~ Moved at index 5')
      expect(report).to include('+ Added at index 10')
    end

    it 'includes detailed special commands' do
      report = detailed_reporter.generate_report
      expect(report).to include('+ Added: new_command')
    end
  end

  describe 'with no differences' do
    let(:no_diff_result) do
      {
        layout: {
          page_count_diff: { changed: false },
          position_differences: { total_differences: 0 },
          dimension_differences: {}
        },
        content: {
          character_count_diff: { difference: 0, changed: false },
          special_commands_diff: { changed: false },
          rules_diff: { changed: false },
          text_differences: { pages_with_differences: 0 }
        },
        fonts: {
          font_usage_diff: { different: false },
          added_fonts: [],
          removed_fonts: [],
          changed_usage: []
        }
      }
    end

    let(:no_diff_reporter) { described_class.new(no_diff_result) }

    it 'reports files as identical' do
      summary = no_diff_reporter.generate_summary
      expect(summary).to include('Total differences detected: 0')
      expect(summary).to include('Files are identical.')
    end
  end
end
