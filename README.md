# Cryptography Source Code Books 

> Don't rule your own crypto in production, but tinker in the sandbox

tl;dr [start here](https://kernoelpanic.github.io/cryptography-   engineering-source-code-books/)

This is a collection of jupyter notebooks which should provide an introduction to cryptography while taking a more practical *hands-on* perspective. Therefore, the notebooks include source code snippets in [sage math](https://www.sagemath.org/) and python. 

**Attention:** The provided code snippets are **not** meant to represent secure production ready implementations, or parts thereof. They are meant for learning purposes.

The goal of the code snippets is it to demonstrate the mathematical concepts in an accessible way targeted for computer science students, or software developers, as well as encourage and enable readers to directly experiment with them. 

Parts of the content in this repo is used in the following courses at the University of Vienna: 
* [Informationssicherheit](https://ufind.univie.ac.at/de/course.html?lv=051061&semester=2026W)
* [Information Security Management](https://ufind.univie.ac.at/de/course.html?lv=052000&semester=2026W)
* [Cryptography](https://ufind.univie.ac.at/en/course.html?lv=052014&semester=2026W)
* [Security and Privacy Engineering](https://ufind.univie.ac.at/en/course.html?lv=052011&semester=2026S)

## Docker 

The jupyter notebooks can be run in a docker container.

You can use `make compose` and `make network` to configure the docker environment and run it with `make run`.
Alternatively, you can install a virtualenv containing jupyterlab directly on your host machine with `make venv`. 


## Reveal.js slides

The jupyter notebooks can be exported as HTML slides using `jupyter-nbconvert` and `reveal.js`.

```bash
$ make html_docker # executes jupyter-nbconvert within the docker container 
```

## Content 

Start with the [index.html](https://kernoelpanic.github.io/cryptography-engineering-source-code-books/). 
