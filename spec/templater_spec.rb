require 'templater'

describe 'Templater' do

  describe '#generate_html' do

    context 'Using <* *> with simple Ruby' do
      it 'handles empty lines' do
        template = "\n\n \n"
        expect(generate_html(template)).to eq("\n\n \n")
      end

      it 'handles Ruby with empty lines between' do
        template = "\n <* 2+2 *> \n \n <html> \n </html>"
        expect(generate_html(template)).to eq("\n 4 \n \n <html> \n </html>")
      end

      it 'handles no space between tag and Ruby' do
        template = "<*2+1*>"
        expect(generate_html(template)).to eq("3")
      end

  end

    context 'Flow control' do
      it 'handles single if' do
        template = "<* IF 2 > 1 *>\n<p> 2 is greater than 1 </p>\n<* END *>"
        expect(generate_html(template)).to eq("\n<p> 2 is greater than 1 </p>\n")
      end

      it 'handles multiple branch if' do
        template = "<* IF 2 < 1 *>\n"
        template += "<p> 2 is less than 1 </p>\n"
        template += "<* ELSIF 2 == 1 *>\n"
        template += "<* ELSE *>\n"
        template += "<p> 2 is greater than 1 </p>\n"
        template += "<* END *>"

        expected_output = "\n<p> 2 is greater than 1 </p>\n"

        expect(generate_html(template)).to eq(expected_output)
      end

      it 'handles unless' do
        template = "<* UNLESS 2 < 0*>\n"
        template += "<p> 2 is a positive integer </p>\n"
        template += "<* END *>"

        expected_output = "\n<p> 2 is a positive integer </p>\n"

        expect(generate_html(template)).to eq(expected_output)
      end
    end

    context 'Looping construct using each' do
      it 'handles a simple loop'
        template = "<* EACH ['some', 'words', 'here'] word *>\n"
        template += ""
      it 'handles a nested loop'
    end

    context 'Accessing JSON data' do
      it 'can access top level keys'

      it 'can access nested keys'

    end

    context 'More complicated Ruby using JSON data' do
      it 'can handle a nested loop with HTML inside'

    end





end



end
