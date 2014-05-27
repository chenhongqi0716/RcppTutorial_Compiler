all : index.html
	R CMD INSTALL RcppTutorialExercise1

%.html : %.Rmd
	Rscript -e "library(slidify);slidify('$<')"
	-rm *.o
	-rm *.so
