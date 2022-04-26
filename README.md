# Slim Bootloader Documentation

This documentation is written in RST (ReStructuredText) format and can be built into web pages using Sphinx rendered with an HTML theme (sphinx-rtd-theme).

## Philosophy

This documentation is meant to help someone who is new to Slim Bootloader project and interested in getting started with the code.


## Getting Started

In order to build the web site content from the source code, install additional python packages:

`pip install sphinx docutils sphinx-rtd-theme sphinxcontrib-websupport`

To make public content:

`make html`

The generated HTML file is located in 'build'.


## Review Your Changes

1. Start a Python HTTP server from the documentation repo's root folder

`cd <documentation repo root folder>`
For Python 2 do `python -m SimpleHTTPServer`, for Python 3 do `python -m http.server`

2. Open your browser to load HTML page from http://localhost:8000/build


## Submit changes (for contributors)

Follow the github workflow to submit your pull request.


## Diving In

If you are not familiar with RST and Sphinx, start with https://restructuredtext.readthedocs.io/en/latest/index.html

With that, start with any file with .rst extension.


## License

See LICENSE file


## Technical Writer's Guide

* Technical details only.  Focus on "how it works".
* Make every subject short and practical
* Focus on design schemes but also make it convenient like recipes
