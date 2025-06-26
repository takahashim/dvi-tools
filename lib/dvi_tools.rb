# frozen_string_literal: true

require_relative 'dvi_tools/version'
require_relative 'dvi_tools/parser'
require_relative 'dvi_tools/analyzer'
require_relative 'dvi_tools/diff_engine'
require_relative 'dvi_tools/reporter'
require_relative 'dvi_tools/cli'

module DviTools
  class Error < StandardError; end
  class ParseError < Error; end
  class FileError < Error; end
end
