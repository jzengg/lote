#!/usr/bin/env ruby
require 'json'
require 'ostruct'

# @author Jimmy Zeng

# This script takes in the file-name for an HTML template, JSON data, and
# optionally a name for the output-file. It writes a new file after parsing
# the input HTML and using the JSON data.
# The files are expected to be in the same directory as the script.

arg_message = 'Not enough arguments. Please use the following format: '
arg_message += './templater [template_name] [data_name] [output_file_name]'
fail arg_message if __FILE__ == $PROGRAM_NAME && ARGV.size < 2

# Arrays to check what kind of keyword a term contains
BLOCK_KEYWORDS = ['EACH']
FLOW_KEYWORDS = ['IF', 'UNLESS', 'ELSE', 'ELSIF']
END_KEYWORDS = ['END']
ALL_KEYWORDS = [END_KEYWORDS, BLOCK_KEYWORDS, FLOW_KEYWORDS]

# Maps type of keyword to a symbol representation
KEYWORDS_SYMBOL = {
  END_KEYWORDS => :end,
  BLOCK_KEYWORDS => :block,
  FLOW_KEYWORDS => :flow }

# Regex to split html for the <* tag
PATTERN = /(<\*)\s*(.*?)\s*\*>/

  # Top level method to capture the arguments passed in and write to an output
  # html file.
  #

  def run
    template_name, data_name, output_name = ARGV
    output_name ||= 'output.html'

    data_object = JSON.parse(IO.read(data_name), object_class: OpenStruct)
    output_html = generate_html(IO.read(template_name), data_object)

    File.open(output_name, 'w') { |file| file.puts output_html }
    puts "Successfully saved to #{output_name}"
  end

  # Generates html using a given template string and data object
  #
  # @param template [string] HTML template file as a string
  # @param context [OpenStruct] JSON data converted into OpenStruct
  # @return [string] output HTML ready to be written to a file

  def generate_html(template, context = self)
    create_proc_to_generate_html(template, context).call
  end

  # Generates a proc with code to build up html as a string
  #
  # @param template [string] HTML template file as a string
  # @param context [OpenStruct] JSON data converted into OpenStruct
  # @return [proc] Returns the output HTML as a string when called

  def create_proc_to_generate_html(template, context)
    terms = template.split(PATTERN)
    stringified_ruby = "Proc.new do |_|\n ; html=''\n"

    # Splits the template up, according to the special tag denoting Ruby <*
    # @example terms = ["<html>\n", "<*", "1+2", "</html>\n"]

    until terms.empty?
      # Go through the terms looking for the <* tag
      current_term = terms.shift
      next_term = terms.first unless terms.empty?

      if ruby_tag?(current_term)
        # Once we find a Ruby tag, we check if the following term is a keyword
        # which won't be printed ex. 'if.' Similar to <% vs <%= in ERB
        keyword_type = keyword_type?(next_term)
        current_term = terms.shift unless keyword_type.nil?

        # Based on the type of keyword the next term contains, we add the
        # correct string to our stringified proc 'stringified_ruby'
        case keyword_type
        when :end then stringified_ruby << "end\n"
        when :block
          parsed_line = parse_block_keyword(current_term)
          stringified_ruby << "#{parsed_line}\n"
        when :flow then stringified_ruby << "#{current_term.downcase}\n"
        else stringified_ruby << "html << (#{terms.shift}).to_s\n"
        end

      else
        stringified_ruby << "html << #{current_term.inspect}\n"
      end
    end
    # Our final line in the proc is to return the html we've built up
    stringified_ruby << 'html; end'
    context.instance_eval(stringified_ruby)
  end

  # Checks whether a term contains a tag that denotes Ruby
  #
  # @param term [string] A piece of the template html passed in
  # @return [boolean]

  def ruby_tag?(term)
    term == '<*'
  end

  # Checks what kind of keyword, if any, a term contains
  #
  # @param term [string] A piece of the template html passed in
  # @return [symbol, nil] The type of keyword present in the term.

  def keyword_type?(term)
    ALL_KEYWORDS.each do |arr|
      return KEYWORDS_SYMBOL[arr] if arr.any? { |keyword| term.include?(keyword) }
    end
    nil
  end

  # Parses a term that contains a loop keyword into Ruby that can be evaluated
  #
  # @param term [string] A piece of the template html passed in
  # @return [string] Stringified Ruby which can be evaluated using instance_eval

  def parse_block_keyword(term)
    method, key, param_name = term.split(' ')
    "#{key}.#{method.downcase} do |#{param_name}|"
  end

run if __FILE__ == $PROGRAM_NAME
