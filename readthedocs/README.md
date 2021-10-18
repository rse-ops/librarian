# ReadtheDocs Librarian

The ReadtheDocs Librarian will help you to deploy a readthedocs site to gh-pages.

## Usage

The GitHub action can be used as follows:

```yaml
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    name: Deploy ReadtheDocs to GitHub Pages
    steps:
      - uses: actions/checkout@v2
      - uses: rse-ops/librarian/readthedocs@main
        with:        
          dir: docs
          
          # Path relative to docs folder specified above
          requirements: requirements.txt 
          token: ${{ secrets.GITHUB_TOKEN }} 
          branch: gh-pages 
```
