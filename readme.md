# lote
A very simple command-line templating engine in Ruby. Takes in an html template file,
a JSON data file and an optional output file name.

## Supports
* Nested looping constructs `each`
* Control flow keywords `if, else, elsif, unless`

## Syntax
* The <\* \*> tag denotes a line that contains Ruby.
* Can index into json data like this:
```html
<body>
  <* player.name *>
</body>
```
```html
<body>
  Draymond Green
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
* Move your template and json file into the directory
* Cd into directory and run templater with the arguments [template_name] [data_name] [output_file_name]
* Using the example files, you would run `./templater example_template.html example_data.json output.html`

## TBD
- [] arstarst
