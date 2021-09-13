#!/usr/bin/env python3

# This script does the following.
# 1. Reads in a container URI and gets all tags (versions)
# 2. Also takes an optional size to share
# 3. Generates metadata for a markdown (yaml) header section

import argparse
from datetime import datetime
import logging
import os
import sys
import requests
from jinja2 import Environment, BaseLoader, select_autoescape

logging.basicConfig(level=logging.INFO)

template = """---
layout: container
name: {{ container }}
updated_at: {{ updated_at }}
{% if size %}size: {{ size }}{% endif %}
{% if raw_size %}raw_size: {{ raw_size }}{% endif %}
container_url: https://github.com/orgs/rse-radiuss/packages/container/package/{{ name }}
versions:
{% for tag, metadata in metadata.items() %} - tag: {{ tag }}
   dockerfile: https://github.com/rse-radiuss/docker-images/blob/main/{{ metadata.dockerfile }}
   manifest: {{ metadata.manifest }}
{% endfor %}
---"""

env = Environment(autoescape=select_autoescape(["html"]), loader=BaseLoader())


def write_file(content, filename):
    with open(filename, "w") as fd:
        fd.write(content)


def get_parser():
    parser = argparse.ArgumentParser(
        description="RADIUSS Docker Images Library Builder"
    )

    description = "Generate a library entry for a container"
    subparsers = parser.add_subparsers(
        help="actions",
        title="actions",
        description=description,
        dest="command",
    )

    gen = subparsers.add_parser("gen", help="generate a library entry")
    gen.add_argument("container", help="container unique resource identifier.")
    gen.add_argument(
        "--outdir",
        "-o",
        dest="outdir",
        help="Write test results to this directory",
    )
    gen.add_argument(
        "--size", dest="size", help="Compressed size of container in MB"
    )
    gen.add_argument(
        "--raw-size", dest="raw_size", help="Raw size of container in MB"
    )

    gen.add_argument(
        "--root",
        dest="root",
        help="Root where tag folders are located",
    )
    gen.add_argument(
        "--dockerfile",
        dest="dockerfile",
        help="Root where Dockerfile is located (that might be shared by > tag)",
    )

    return parser


def main():
    parser = get_parser()

    def help(return_code=0):
        parser.print_help()
        sys.exit(return_code)

    # If an error occurs while parsing the arguments, the interpreter will exit with value 2
    args, extra = parser.parse_known_args()
    if not args.command:
        help()

    # Container can't have a tag
    if ":" in args.container:
        sys.exit("%s has a tag, it should not! (found ':')" % args.container)

    # Get tags for the container
    response = requests.get("https://crane.ggcr.dev/ls/" + args.container)
    if response.status_code != 200:
        sys.exit("Issue retrieving manifest for %s" % args.container)
    tags = [x for x in response.text.split("\n") if x]

    # Prepare set of metadata for each
    metadata = {tag: {} for tag in tags}

    # manifests
    for tag in tags:
        metadata[tag]["manifest"] = (
            "https://crane.ggcr.dev/manifest/" + args.container + ":" + tag
        )

    # Prepare paths to dockerfiles
    if args.root:
        for tag in tags:
            metadata[tag]["dockerfile"] = os.path.join(args.root, tag, "Dockerfile")
    elif args.dockerfile:
        for tag in tags:
            metadata[tag]["dockerfile"] = os.path.join(args.dockerfile, "Dockerfile")

    # Render into template!
    result = env.from_string(template).render(
        metadata=metadata,
        size=args.size,
        raw_size=args.raw_size,
        container=args.container,
        versions=tags,
        name=os.path.basename(args.container),
        updated_at=datetime.now(),
    )
    print(result)
    if args.outdir == ".":
        args.outdir = os.getcwd()
    filename = os.path.join(args.outdir, "%s.md" % args.container.replace("/", "-"))
    write_file(result, filename)
    print("::set-output name=filename::%s" % filename)


if __name__ == "__main__":
    main()
