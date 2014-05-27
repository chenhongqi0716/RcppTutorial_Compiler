#include <Rcpp.h>

using namespace Rcpp;

//[[Rcpp::export]]
void hello() {
  Rcout << "hello" << std::endl;
}

/*** R
hello()
*/
