#include <string>
#include <Rcpp.h>

//[[Rcpp::export]]
int error2() {
  std::string i("hello world");
  return i;
}
