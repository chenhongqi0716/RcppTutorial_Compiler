.sourceEx <- function(i) {
  sourceCpp(system.file(sprintf("exercise/ex1.%d.cpp", i), package="RcppTutorialExercise1"))
}

ex1.1 <- function() {
  .sourceEx(1)  
}

ans1.1 <- function(i) i == 4

ex1.2 <- function() {
  .sourceEx(2)  
}

ans1.2 <- function(i) i == 2


ex1.3 <- function() {
  .sourceEx(3)  
}

ans1.3 <- function(i) i == 1

ex1.4 <- function() {
  .sourceEx(4)
}

ans1.4 <- function(i) i == 7

ex1.5 <- function() {
  .sourceEx(5)
}

ans1.5 <- function(i) i == 3

