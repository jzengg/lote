# lote
A very simple command-line templating engine in Ruby. Takes a template file-name,
a JSON file-name and an optional output file-name as arguments. More
documentation available in doc/index.html

## Supports
* Nested looping constructs using `each`
* Flow control keywords `if, else, elsif, unless`

## Syntax
* The `<* *>` tag denotes a line that contains Ruby.
* Say you have data that looks like this
```json
{
  "page": {
    "title": "NBA"
  },
  "teams": [
    {"name": "New York Knicks"},
    {"name": "San Antonio Spurs"}
  ],
  "players": [
    { "name": "Kawhi Leonard", "nicknames": ["The Claw"] },
    { "name": "Draymond Green", "nicknames": ["BDD", "Dray"] }
  ]
}
```
* Inside of `<* *>`, self refers to the JSON data.
* So you can access the data like this (self can be omitted)
```html
<body>
  <* page.title *>
</body>
```
```html
<body>
  NBA
</body>
```
* Looping through players looks like this:
```html
<ul>
  <* EACH players player *>
    <li> <* player.name *> </li>
  <* ENDEACH *>
</ul>
```
```html
<ul>
  <li> Draymond Greend </li>
  <li> Kawhi Leonard </li>
</ul>
```

## How to use
* Clone this repo
* Move your template and json file into the lib directory
* cd into directory and run templater with the arguments [template_name] [data_name] [output_file_name]
* Using the example files, you would run `./templater.rb example_template.html example_data.json output.html`

## Todo
- [x] basic testing
- [ ] use a regex/grep or another method to avoid using ostruct
- [ ] support master template file that lists other template files to read
- [ ] partials with '\_file-name' convention
- [ ] testing for #run
- [ ] more advanced testing using aruba + rspec
- [ ] Thor for more command-line options
