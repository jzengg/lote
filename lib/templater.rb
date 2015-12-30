#!/usr/bin/env ruby
require 'json'
require 'ostruct'

arg_message = 'Not enough arguments. Please use the following format: '
arg_message += './templater [template_name] [data_name] [output_file_name]'
fail arg_message if __FILE__ == $PROGRAM_NAME && ARGV.size < 2

BLOCK_KEYWORDS = ['EACH']
FLOW_KEYWORDS = ['IF', 'UNLESS', 'ELSE', 'ELSIF']
END_KEYWORDS = ['END']
ALL_KEYWORDS = [END_KEYWORDS, BLOCK_KEYWORDS, FLOW_KEYWORDS]
KEYWORDS_SYMBOL = {
  END_KEYWORDS => :end,
  BLOCK_KEYWORDS => :block,
  FLOW_KEYWORDS => :flow }

PATTERN = /(<\*)\s*(.*?)\s*\*>/

def run
  template_name, data_name, output_name = ARGV
  output_name ||= 'output.html'

  data_object = JSON.parse(IO.read(data_name), object_class: OpenStruct)
  output_html = generate_html(IO.read(template_name), data_object)

  File.open(output_name, 'w') { |file| file.puts output_html }
  puts "Successfully saved to #{output_name}"
end

def generate_html(template, context = self)
  create_proc_to_generate_html(template, context).call
end

def create_proc_to_generate_html(template, context)
  terms = template.split(PATTERN)
  stringified_ruby = "Proc.new do |_|\n ; html=''\n"

  until terms.empty?
    current_term = terms.shift
    next_term = terms.first unless terms.empty?

    if ruby_tag?(current_term)
      keyword_type = keyword_type?(next_term)
      current_term = terms.shift unless keyword_type.nil?

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

  stringified_ruby << 'html; end'
  context.instance_eval(stringified_ruby)
end

def ruby_tag?(term)
  term == '<*'
end

def keyword_type?(term)
  ALL_KEYWORDS.each do |arr|
    return KEYWORDS_SYMBOL[arr] if arr.any? { |keyword| term.include?(keyword) }
  end
  nil
end

def parse_block_keyword(term)
  method, key, param_name = term.split(' ')
  "#{key}.#{method.downcase} do |#{param_name}|"
end

run if __FILE__ == $PROGRAM_NAME
