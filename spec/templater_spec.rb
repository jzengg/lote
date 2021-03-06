require 'templater'

describe Templater do

  describe '#generate_html' do
    let(:templater) { Templater.new }
    context 'Using <* *> with Ruby' do

      context 'Basic Ruby' do
      it 'handles empty lines' do
        template = "\n\n \n"
        expect(templater.generate_html(template)).to eq("\n\n \n")
      end

      it 'handles Ruby strings' do
        template = "<* 'string' *>"
        expect(templater.generate_html(template)).to eq("string")
      end

      it 'handles extra empty lines' do
        template = "\n <* 2+2 *> \n \n <html> \n </html>"
        expect(templater.generate_html(template)).to eq("\n 4 \n \n <html> \n </html>")
      end

      it 'handles no space between tag and Ruby' do
        template = "<*2+1*>"
        expect(templater.generate_html(template)).to eq("3")
      end
    end

    context 'Looping constructs' do
      it 'handles array literals' do
        template = "<* EACH [1,2,3] num *>\n"
        template += "<* num *>\n"
        template += "<* ENDEACH *>"

        expect(templater.generate_html(template)).to eq("\n1\n\n2\n\n3\n")
      end

      # can probably fix with a regex in #parse_block_keyword
      it 'handles array literals with a space between elements' do
        template = "<* EACH [1, 2, 3] num *>\n"
        template += "<* num *>\n"
        template += "<* ENDEACH *>"

        expect(templater.generate_html(template)).to eq("\n1\n\n2\n\n3\n")
      end

    end

    context 'Flow control' do
      it 'handles single if' do
        template = "<* IF 2 > 1 *>\n<p> 2 is greater than 1 </p>\n<* END *>"
        expect(templater.generate_html(template)).to eq("\n<p> 2 is greater than 1 </p>\n")
      end

      it 'handles multiple branch if' do
        template = "<* IF 2 < 1 *>\n"
        template += "<p> 2 is less than 1 </p>\n"
        template += "<* ELSIF 2 == 1 *>\n"
        template += "<* ELSE *>\n"
        template += "<p> 2 is greater than 1 </p>\n"
        template += "<* END *>"

        expected_output = "\n<p> 2 is greater than 1 </p>\n"

        expect(templater.generate_html(template)).to eq(expected_output)
      end

      it 'handles unless' do
        template = "<* UNLESS 2 < 0*>\n"
        template += "<p> 2 is a positive integer </p>\n"
        template += "<* END *>"

        expected_output = "\n<p> 2 is a positive integer </p>\n"

        expect(templater.generate_html(template)).to eq(expected_output)
      end
    end

  end

    context 'Using JSON data' do
      let (:data) do
        json = {
          title: "Testing",
          people: [
            { name: "Jason", nicknames: ["J", "JACE"] },
            { name: "Jake", nicknames: ["JAKESTER"] }
          ]
        }.to_json
        JSON.parse(json, object_class: OpenStruct)
      end

      context 'Simple cases of accessing data' do

        it 'within <* *> tags, self is the JSON data' do
          template = "<* self *>"
          expect(templater.generate_html(template, data)).to eq(data.inspect)
        end

        it 'can access top level keys' do
          template = "<* title *>"
          expect(templater.generate_html(template, data)).to eq("Testing")
        end

        it 'can access nested keys' do
          template = "<* people.first.name *>"
          expect(templater.generate_html(template, data)).to eq("Jason")
        end

      end

      context 'Looping through data' do

        it 'handles a simple loop' do
          template = "<* EACH people person *>\n"
          template += "<* person.name *>\n"
          template += "<* ENDEACH *>"

          expected_output = "\nJason\n\nJake\n"
          expect(templater.generate_html(template, data)).to eq(expected_output)
        end

        it 'handles a nested loop' do
          template = "<* EACH people person *>\n"
          template += "<h1> <* person.name *> </h1>\n"
          template += "<* EACH person.nicknames nickname *>\n"
          template += "<p> <* nickname *> </p>\n"
          template += "<* ENDEACH *>\n"
          template += "<* ENDEACH *>"

          expected_output = "\n<h1> Jason </h1>\n\n<p> J </p>\n\n<p> JACE </p>\n"
          expected_output += "\n\n<h1> Jake </h1>\n\n<p> JAKESTER </p>\n\n"
          expect(templater.generate_html(template, data)).to eq(expected_output)
        end
      end

    end

  end

  describe '#run' do

    context 'Passing in arguments from command-line' do
      it 'reads first argument as template'

      it 'reads second argument given as JSON data'

      it 'writes to file-name given by third argument'

      it 'defaults to output.html if only 2 arguments given'
    end

  end

end
