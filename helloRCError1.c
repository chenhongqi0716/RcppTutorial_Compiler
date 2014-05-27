#include <R.h>
#include <Rdefines.h>
#include <stdio.h>
SEXP helloRC() {
  Rprintf("Hello World!\n")
  return(R_NilValue);
}
