# Cryptography Engineering Source Code Books 

🚧 **work-in-progress** 🚧

This is a collection of jupyter notebooks which should provide an introduction to cryptography while taking a more practical *hands-on* engineering perspective. Therefore, the notebooks include source code snippets mostly in [sage math](https://www.sagemath.org/) and python. 

**Attention:** The provided code snippets are **not** meant to represent secure functioning implementations or parts thereof.
They are for learning purposes only!

The goal of the code snippets is it to demonstrate the mathematical concepts in an accessible way targeted for computer science students, or software developers, as well as encourage and enable readers to directly experiment with what they learn. 

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

Start with the [index.html](./index.html). 
