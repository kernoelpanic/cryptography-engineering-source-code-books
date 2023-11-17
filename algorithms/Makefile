# execute twice since the files have to be found at the beginning 
# of execution 
# $ make clean && make && make && make cleanup && sxiv binarymultiplication.png

TEX_TO_PDF_FILES=$(patsubst %.tex,%.pdf,$(wildcard *.tex))
PDF_TO_PNG_FILES=$(patsubst %.pdf,%.png,$(wildcard *.pdf))

all: textopdf pdftopng #cleanup ##dont cleanup
.PHONY: .FORCE

%.pdf : %.tex .FORCE
	pdflatex $<
.FORCE:

%.png : %.pdf .FORCE
	convert -density 300 $< -resize "40%" $@
.FORCE:

textopdf: $(TEX_TO_PDF_FILES)
	#@echo $(TEX_TO_PDFFILES)

pdftopng: $(PDF_TO_PNG_FILES)
	#@echo $(PDF_TO_PNG_FILES) 

cleanup: 
	echo "cleaning up..."
	-rm *.aux
	-rm *.log
	-rm *.dvi
	-rm *.pdf

clean: cleanup
	-rm *.svg
	-rm *.png
