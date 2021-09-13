# Docker Images Librarian

The Docker images librarian will take, as input, a container URI, 
calculate the size for it, and generate a markdown metadata file in a directory
of interest.

It uses the small script [update-site.py](update-site.py) to do this:

```
./update-site.py gen -h
usage: update-site.py gen [-h] [--outdir OUTDIR] [--size SIZE] [--root ROOT] [--dockerfile DOCKERFILE] container

positional arguments:
  container             container unique resource identifier.

optional arguments:
  -h, --help            show this help message and exit
  --outdir OUTDIR, -o OUTDIR
                        Write test results to this directory
  --size SIZE           Size of container in MB
  --root ROOT           Root where tag folders are located
  --dockerfile DOCKERFILE
                        Root where Dockerfile is located (that might be shared by > tag)
```

## Usage

The GitHub action can be used as follows:

```yaml
on: [push]

jobs:
  librarian:
    runs-on: ubuntu-latest
    name: Run Librarian
    steps:
      - uses: actions/checkout@v2

      # **Run steps in here to define outputs for container, etc.**

      - id: runner
        uses: rse-radiuss/librarian/docker-images@main
        with:
        
          # Container is required, without tag e.g., ghcr.io/rse-radiuss/ubuntu
          container: ${{ steps.builder.outputs.container }}
          token: ${{ secrets.GITHUB_TOKEN }} 
          
          # ONE of dockerfile OR root should be defined. Root is for dockerhierarchy builds
          # and dockerfile is for a single directory with a Dockerfile
          dockerfile: ${{ steps.builder.outputs.dockerfile }}
          root: ${{ steps.builder.outputs.root }}
          
          # Deploy to the branch "gh-pages" (defualt) on the same repository in ./_library
          branch: gh-pages 
          deploy: true
          outdir: ./_library

      - run: echo ${{ steps.runner.outputs.filename }}
        shell: bash
```

The script can also run via the main branch of this same repository, and if needed,
you can also run commands manually. As an example:


```bash
# For a Dockerfile build where the tag is in subfolders under ubuntu
$ python scripts/update-site.py gen ghcr.io/rse-radiuss/ubuntu --outdir $PWD/_library --root ubuntu/

# For a matrix build where the Dockerfile is in the root provided
$ python scripts/update-site.py gen ghcr.io/rse-radiuss/nvidia-ubuntu --outdir $PWD/_library --dockerfile nvidia-ubuntu
$ python scripts/update-site.py gen ghcr.io/rse-radiuss/clang-ubuntu-20.04 --outdir $PWD/_library --dockerfile ubuntu/clang
$ python scripts/update-site.py gen ghcr.io/rse-radiuss/cuda-ubuntu-20.04 --outdir $PWD/_library --dockerfile ubuntu/cuda
```

