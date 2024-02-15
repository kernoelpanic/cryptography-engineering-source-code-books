#/bin/bash

# Templates:
# https://nbconvert.readthedocs.io/en/latest/customizing.html#where-are-nbconvert-templates-installed
# try a custom template, default for slides is
# --template reveal
# (.venv) workuser@docker/ubuntu_ppt:/workdir$ jupyter --paths
#config:
#    /workdir/.venv/etc/jupyter
#    /home/workuser/.jupyter
#    /usr/local/etc/jupyter
#    /etc/jupyter
#data:
#    /workdir/.venv/share/jupyter
#    /home/workuser/.local/share/jupyter
#    /usr/local/share/jupyter
#    /usr/share/jupyter
#runtime:
#    /home/workuser/.local/share/jupyter/runtime 
# 
#Probably this is used:
#/workdir/.venv/share/jupyter/nbconvert/templates/reveal
#
#--reveal-prefix
#https://github.com/hakimel/reveal.js
# 
#--SlidesExporter.reveal_theme= \
#``reveal_url_prefix``/css/theme/``reveal_theme``.css
# Actually it is: /dist/theme/
#
# Help about commands:
# jupyter-nbconvert --help-all

jupyter nbconvert \
			--to slides  \
			`#--nbformat=2` \
			--template reveal \
			--reveal-prefix=./reveal.js \
			--SlidesExporter.reveal_number='c' \
			--SlidesExporter.reveal_scroll=True \
			--SlidesExporter.reveal_theme=simple \
			`#--SlidesExporter.reveal_theme=night` \
			*.ipynb
			#--post serve \
			`#--ServePostProcessor.reveal_cdn='https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.5.0'` \
			#--ServePostProcessor.ip='0.0.0.0' \
			#--ServePostProcessor.open_in_browser=False \
			#ppt.ipynb

jupyter nbconvert --to html index.ipynb

if [ -d "./solutions" ]; then
	jupyter nbconvert \
      --to slides  \
      `#--nbformat=2` \
      --template reveal \
      --reveal-prefix=./reveal.js \
      --SlidesExporter.reveal_number='c' \
      --SlidesExporter.reveal_scroll=True \
      --SlidesExporter.reveal_theme=simple \
      solutions/*.ipynb
fi
