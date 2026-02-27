# Localise YAML headers within Pandoc

This is a [Haskell filter for Pandoc](https://pandoc.org/filters.html) which allows you to set different strings in your metadata for different localisations. Especially handy if you use a Pandoc template for your CV.

## How it works

Imagine you use YAML to store your CV, and then generate a human-readable document from that YAML file.^[This is the philosophy of many existing projects, such as [YAML-CV](https://github.com/lgloege/YAML-CV) and [pandoc_resume_template](https://github.com/samijuvonen/pandoc_resume_template) (using pandoc), [YAMLResume](https://yamlresume.dev/) (using LaTeX) or [RenderCV](https://rendercv.com/) (using Typst).] Then your `cv.yaml` file might look something like

```yaml
name: Jane Smith
profession: Underwater basket weaver
birthday: January 3^rd^, 1234
```

The problem comes if you are likely to need your CV in different languages for different purposes. One option is to maintain several copies of `cv.yaml`, one for each language; but that quickly becomes tedious, and what if some information is shared across documents and needs to be updated? The ideal would be to write different-language versions of each string right next to each other, so they can be quickly checked for errors and updated simultaneously. 

This filter (`pandoc-localise-yaml`) allows you to write, at any level of your YAML file, a prefix specifying which language the following field applies to. For example:

```yaml
name: Jane Smith
profession: 
  en: Underwater basket weaver
  fr: Enseignante d'aquagym au sec
  it: Tozzabanconara
birthday: 
  en: January 1^st^, 1234
  fr: 3 janvier 1234
  it: 3 gennaio 1234
lang: it
```

The filter will then select only those elements which are marked by the desired output language. The desired output language is determined by the special keyword `lang: xxx` at the top-most level of the YAML data.

In particular, applying `pandoc-localise-yaml` to the above YAML will output:

```yaml
name: Jane Smith
profession: Tozzabanconara
birthday: 3 gennaio 1234
lang: it
```


The filter accepts any string for the language code, but I recommend using the standard two- or three-letter [ISO codes](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes). If you do so, the filter allows you to specify a regional variant (*e.g.*, `en-UK`) and will select that text, falling back on the prefix `en` if no `en-UK` variant is available. For example,

```yaml
name: Georges de la Gruyère
profession:
  en: Eighty years a beggar
  fr: Mendiant depuis quatre-vingt ans
  fr-CH: Mendiant depuis huitante ans
birthday:
  en: January 1^st^, 1234
  fr: 3 janvier 1234
lang: fr-CH
```

will become 

```yaml
name: Georges de la Gruyère
profession: Mendiant depuis huitante ans
birthday: 3 janvier 1234
lang: fr-CH
```


## Usage

Follow the instructions from the [Pandoc site](https://pandoc.org/filters.html).

The [testing](testing/) folder provides a pre-compiled binary that works for `x86_64-linux` architectures. To use it, download all files in that folder, and run 

```bash
pandoc test.md -s -o output.md --filter ./pandoc-localise-yaml
```

(Make sure that you have Pandoc installed.) You'll notice that the new markdown file `output.md` only keeps the fields marked with the localisation `fr-CH` or `fr`.

## Improvements

I don't know how to publish this kind of project so that it's easily usable as a pandoc filter with the syntax `--filter pandoc-localise-yaml` without installing any extra programs. If anyone wants to give me a hand and/or provide a pull request with that implemented, it's very welcome!
