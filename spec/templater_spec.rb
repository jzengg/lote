require 'templater'

describe 'Templater' do

  describe '#generate_html' do

    context 'Using <* *> with simple Ruby' do
      it 'handles empty lines' do
        template = "\n\n \n"
        expect(generate_html(template)).to eq("\n\n \n")
      end

      it 'handles Ruby strings' do
        template = "<* 'string' *>"
        expect(generate_html(template)).to eq("string")
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


    context 'JSON data' do
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
          expect(generate_html(template, data)).to eq(data.inspect)
        end

        it 'can access top level keys' do
          template = "<* title *>"
          expect(generate_html(template, data)).to eq("Testing")
        end

        it 'can access nested keys' do
          template = "<* people.first.name *>"
          expect(generate_html(template, data)).to eq("Jason")
        end

      end

      context 'Looping construct using each' do
        it 'handles a simple loop' do
          template = "<* EACH people person *>\n"
          template += "<* person.name *>\n"
          template += "<* ENDEACH *>"

          expected_output = "\nJason\n\nJake\n"
          expect(generate_html(template, data)).to eq(expected_output)
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
          expect(generate_html(template, data)).to eq(expected_output)
        end
      end

    end

  end
end
