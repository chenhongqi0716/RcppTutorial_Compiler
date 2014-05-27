#include <string>
#include <Rcpp.h>
#include "error3.h"

//[[Rcpp::export]]
int error2() {
  return error3();
}
