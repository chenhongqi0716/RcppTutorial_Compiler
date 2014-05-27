#include <string>
#include <Rcpp.h>

//[[Rcpp::export]]
int error2() {
  return error3();
}
