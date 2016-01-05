#!/usr/bin/env ruby
require 'json'
require 'ostruct'

# @author Jimmy Zeng
#
# This script takes in the file-name for an HTML template, JSON data, and
# optionally a name for the output-file. It writes a new file after parsing
# the input HTML using the JSON data and evaluating Ruby as needed.
# The template and data files should be in the same directory as the script.
class Templater
  BLOCK_KEYWORDS = ['EACH']
  FLOW_KEYWORDS = ['IF', 'UNLESS', 'ELSE', 'ELSIF']
  END_KEYWORDS = ['END']
  ALL_KEYWORDS = [END_KEYWORDS, BLOCK_KEYWORDS, FLOW_KEYWORDS]

  # Maps type of keyword to a symbol representation
  KEYWORDS_SYMBOL = {
    END_KEYWORDS => :end,
    BLOCK_KEYWORDS => :block,
    FLOW_KEYWORDS => :flow }

  # Regex to split html for the '<*' tag. A space between the tag and the
  # Ruby is optional.
  PATTERN = /(<\*)\s*(.*?)\s*\*>/

  # Top level method to capture the arguments passed in and write to an output
  # html file.
  def run
    check_min_args

    template_name, data_name, output_name = ARGV
    output_name ||= 'output.html'
    # Use OpenStruct instead of the Hash default to accomodate dot notation in
    # the template file
    data_object = JSON.parse(IO.read(data_name), object_class: OpenStruct)
    output_html = generate_html(IO.read(template_name), data_object)

    File.open(output_name, 'w') { |file| file.puts output_html }
    puts "Successfully saved to #{output_name}"
  end

  # Basic check to make sure a minimum number of arguments is given
  def check_min_args
    arg_message = 'Not enough arguments. Please use the following format: '
    arg_message += './templater.rb [template_name] [data_name] [output_name]'
    fail arg_message if ARGV.size < 2
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
  # @return [proc] Proc that returns the output HTML as a string when called
  def create_proc_to_generate_html(template, context)
    # Example: terms = ["<html>\n", "1+2", "<*", "</html>\n"]
    terms = template.split(PATTERN).reverse
    # The base for the stringified proc which will be evaluated
    stringified_ruby = "Proc.new do |_|\n ; html=''\n"

    until terms.empty?
      # Go through the terms looking for the <* tag.
      current_term = terms.pop
      if ruby_tag?(current_term)
        # If we find a Ruby tag, we reassign current_term to the contents of
        # the tag and add the appropriate line to our proc
        current_term = terms.pop
        stringified_ruby << parse_term(current_term)
      # If the term does not contain the <* tag, then it is presumably plain
      # html and we add a line in the proc to insert it into the string
      else
        stringified_ruby << "html << #{current_term.inspect}\n"
      end
    end
    # Our final line in the proc is to return the html we've built up
    stringified_ruby << 'html; end'
    # Evaluate the stringified proc using the OpenStruct json as the context
    context.instance_eval(stringified_ruby)
  end

  # Returns the appropriate string to add to stringified_ruby based on the
  # contents of the tag passed in
  #
  # @param current_term [string] Contents of the tag passed in as a string
  # @return [string] The correct string to add to stringified_ruby
  def parse_term(term)
    keyword_type = keyword_type?(term)
    case keyword_type
    when :end then "end\n"
    when :block
      parsed_line = parse_block_keyword(term)
      "#{parsed_line}\n"
    when :flow then "#{term.downcase}\n"
    # if no special keyword, then insert interpolated term directly into html
    else "html << (#{term}).to_s\n"
    end
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
      # Check each set of keywords to see what kind of keyword a term contains
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

end

Templater.new.run if __FILE__ == $PROGRAM_NAME
