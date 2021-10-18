# ReadtheDocs Librarian

The ReadtheDocs Librarian will help you to deploy a readthedocs site to gh-pages.

## Usage

The GitHub action can be used as follows:

```yaml
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    name: Deploy ReadTheDocs to GitHub Pages
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

To customize to deploy on merge to main, and build on a pull request:


```yaml
on: 
  push:
    branches:
      - main  
  pull_request: []

jobs:
  deploy:
    runs-on: ubuntu-latest
    name: Deploy ReadTheDocs to GitHub Pages
    steps:
      - uses: actions/checkout@v2

        # Buid on push (but no deploy)
      - uses: rse-ops/librarian/readthedocs@main
        if: (github.event_name == 'push')

        if: (github.event_name == 'pull_request')
      - uses: rse-ops/librarian/readthedocs@main
        if: (github.event_name == 'push')
        with:        
          token: ${{ secrets.GITHUB_TOKEN }} 
          deploy: "false"
```



