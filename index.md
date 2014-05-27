---
title       : 工欲善其事，必先利其器
subtitle    : 
author      : Wush Wu
job         : Taiwan R User Group
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
logo        : Taiwan-R-logo.png
--- .segue .dark




## 課前須知

--- &vcenter .large

課程目標

### 初步了解Rcpp的運作原理

### 初步了解編譯器的使用

### 掌握編譯過程錯誤的訊息

--- &twocol

## 環境設定

*** =left

### 程式版本

- R (>= 3.0)
- Rcpp (>= 0.11)

*** =right


```r
R.Version()$version.string
```

```
## [1] "R version 3.0.3 (2014-03-06)"
```

```r
packageVersion("Rcpp")
```

```
## [1] '0.11.1'
```

```r
library(Rcpp)
cppFunction(code='
void hello() {
  Rcout << "hello" << std::endl;
}')
hello()# 應該出現hello
```

```
## hello
```


--- .segue .dark

## Rcpp 的運作原理

--- &vcenter .large

R 是 C 寫的

```
typedef struct SEXPREC {
    SEXPREC_HEADER;
    union {
  struct primsxp_struct primsxp;
	struct symsxp_struct symsxp;
	struct listsxp_struct listsxp;
	struct envsxp_struct envsxp;
	struct closxp_struct closxp;
	struct promsxp_struct promsxp;
    } u;
} SEXPREC, *SEXP;
```

--- &vcenter .large

R 有釋出C 的API


```c
#include <R.h>
#include <Rdefines.h>
#include <stdio.h>
SEXP helloRC() {
  Rprintf("Hello World!\n");
  return(R_NilValue);
}
```


--- &vcenter .large

利用R 呼叫GCC編譯helloRC.c

```
R CMD SHLIB helloRC.c
```

```
gcc -I/opt/local/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I/o
pt/local/include    -fPIC  -pipe -Os -flax-vector-conversions -arch x86_64  -c h
elloRC.c -o helloRC.o
gcc -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -sing
le_module -multiply_defined suppress -L/opt/local/lib -Wl,-headerpad_max_install
_names -arch x86_64 -o helloRC.so helloRC.o -F/opt/local/Library/Frameworks/R.fr
amework/.. -framework R -Wl,-framework -Wl,CoreFoundation

```

--- &vcenter .large

R 很多內建函數的也是C 函數

```
SEXP savehistory(SEXP call, SEXP op, SEXP args, SEXP env)
{
    SEXP sfile;

    args = CDR(args);
    sfile = CAR(args);
    // ...
}
```

--- &vcenter .large

程式碼經過編譯後，再由機器執行

### C/C++ 先由編譯器編譯成機器碼後，才執行

### R 執行的時候才由直譯器轉成機器碼後，才執行

--- .segue .dark

## 認識編譯器

--- &vcenter .large

機器語言

<code>00000 10011110</code>

--- &vcenter .large

把程式碼變成機器語言

<code>
Rcout << "hello" << std::endl;
</code>

Magic!!

<code>
0101...
</code>

--- &vcenter .large

變魔術的(簡易)過程：

`.cpp` $\Rightarrow$ `.o` $\Rightarrow$ `.so`或`.dll`

--- &twocolvcenter .large

*** =left

<center><h1>`hello.cpp` $\Rightarrow$ `hello.o`</h1></center>

## 編譯

### 前置處理

### 編譯

### 組譯

*** =right

<center><h1>`hello.o` $\Rightarrow$ `hello.so`</h1></center>

## 連結

--- &vcenter .large

編譯器的參數

```
gcc -I/opt/local/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I/o
pt/local/include    -fPIC  -pipe -Os -flax-vector-conversions -arch x86_64  -c h
elloRC.c -o helloRC.o
gcc -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -sing
le_module -multiply_defined suppress -L/opt/local/lib -Wl,-headerpad_max_install
_names -arch x86_64 -o helloRC.so helloRC.o -F/opt/local/Library/Frameworks/R.fr
amework/.. -framework R -Wl,-framework -Wl,CoreFoundation

```

### `-I`, `-L`, `-l`, `-O2`, `-D`

--- .segue .dark

## 掌握編譯過程錯誤的訊息

--- &vcenter .large

編譯期錯誤(Compile Time Error)

連結期錯誤(Linking Error)

執行期錯誤(Runtime Error)

--- &vcenter .large

編譯期錯誤: 語法錯誤

```
#include <R.h>
#include <Rdefines.h>
#include <stdio.h>
SEXP helloRC() {
  Rprintf("Hello World!\n")
  return(R_NilValue);
}

```

```
gcc -I/opt/local/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I/o
pt/local/include    -fPIC  -pipe -Os -flax-vector-conversions -arch x86_64  -c h
elloRCError1.c -o helloRCError1.o
helloRCError1.c: In function 'helloRC':
helloRCError1.c:6:3: error: expected ';' before 'return'
make[1]: *** [helloRCError1.o] Error 1

```

--- &vcenter .large

編譯期錯誤: 找不到檔案

```
#include <string>
#include <Rcpp.h>

//[[Rcpp::export]]
int error2() {
  const int i = 2;
  return i;
}

```

```
g++ -I/opt/local/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I/o
pt/local/include    -fPIC  -pipe -Os -arch x86_64  -c helloRCError2.cpp -o hello
RCError2.o
helloRCError2.cpp:2:18: fatal error: Rcpp.h: No such file or directory
compilation terminated.
make[1]: *** [helloRCError2.o] Error 1

```

--- &vcenter .large

編譯期錯誤: 形態錯誤

```
#include <string>
#include <Rcpp.h>

//[[Rcpp::export]]
int error2() {
  std::string i("hello world");
  return i;
}

```

```
g++ -I/opt/local/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I/o
pt/local/include   -I/Users/wush/Library/R/3.0/library/Rcpp/include -fPIC  -pipe
 -Os -arch x86_64  -c helloRCError2.cpp -o helloRCError2.o
helloRCError2.cpp: In function 'int error2()':
helloRCError2.cpp:7:10: error: cannot convert 'std::string {aka std::basic_strin
g<char>}' to 'int' in return
make[1]: *** [helloRCError2.o] Error 1

```

--- &vcenter .large

編譯期錯誤: 找不到宣告

```
#include <string>
#include <Rcpp.h>

//[[Rcpp::export]]
int error2() {
  return error3();
}

```

```
[1] "g++ -I/opt/local/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I/opt/local/include   -I/Users/wush/Library/R/3.0/library/Rcpp/include -fPIC  -pipe -Os -arch x86_64  -c helloRCError3.cpp -o helloRCError3.o"
[2] "helloRCError3.cpp: In function 'int error2()':"                                                                                                                                                                            
[3] "helloRCError3.cpp:6:17: error: 'error3' was not declared in this scope"                                                                                                                                                    
[4] "make[1]: *** [helloRCError3.o] Error 1"                                                                                                                                                                                    
attr(,"status")
[1] 1
g++ -I/opt/local/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I/o
pt/local/include   -I/Users/wush/Library/R/3.0/library/Rcpp/include -fPIC  -pipe
 -Os -arch x86_64  -c helloRCError3.cpp -o helloRCError3.o
helloRCError3.cpp: In function 'int error2()':
helloRCError3.cpp:6:17: error: 'error3' was not declared in this scope
make[1]: *** [helloRCError3.o] Error 1

```

--- &vcenter .large

連結期錯誤: 找不到檔案

```
#include <string>
#include <Rcpp.h>
#include "error3.h"

//[[Rcpp::export]]
int error2() {
  return error3();
}

```

```
g++ -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -sing
le_module -multiply_defined suppress -L/opt/local/lib -Wl,-headerpad_max_install
_names -arch x86_64 -o helloRCError4.so helloRCError4.o nofile.o -F/opt/local/Li
brary/Frameworks/R.framework/.. -framework R -Wl,-framework -Wl,CoreFoundation
g++: error: nofile.o: No such file or directory
make[1]: *** [helloRCError4.so] Error 1

```

--- &vcenter .large

連結期錯誤: 找不到定義

```
#include <string>
#include <Rcpp.h>
#include "error3.h"

//[[Rcpp::export]]
int error2() {
  return error3();
}

```

```
無法載入共享物件 '/Users/wush/Projects/RTutorial/Rcpp_Tutorial_Compiler/helloRCError4.so
' ：
 dlopen(/Users/wush/Projects/RTutorial/Rcpp_Tutorial_Compiler/helloRCError4.
so, 6): Symbol not found: __Z6error3v
  Referenced from: /Users/wush/Projects/RT
utorial/Rcpp_Tutorial_Compiler/helloRCError4.so
  Expected in: flat namespace
 i
n /Users/wush/Projects/RTutorial/Rcpp_Tutorial_Compiler/helloRCError4.so

```

--- &vcenter .large

常見錯誤與相關訊息

<!-- html table generated in R 3.0.3 by xtable 1.7-3 package -->
<!-- Wed May 28 00:00:03 2014 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> 錯誤原因 </TH> <TH> 關鍵字 </TH>  </TR>
  <TR> <TD align="right"> 1 </TD> <TD> 編譯期錯誤: 語法錯誤 </TD> <TD> error: expected  </TD> </TR>
  <TR> <TD align="right"> 2 </TD> <TD> 編譯期錯誤: 找不到檔案 </TD> <TD> fatal error: *** No such file or directory </TD> </TR>
  <TR> <TD align="right"> 3 </TD> <TD> 編譯期錯誤: 形態錯誤 </TD> <TD> error: cannot convert *** to *** in return </TD> </TR>
  <TR> <TD align="right"> 4 </TD> <TD> 編譯期錯誤: 找不到宣告 </TD> <TD> error: *** was not declared in this scope </TD> </TR>
  <TR> <TD align="right"> 5 </TD> <TD> 連結期錯誤: 找不到檔案 </TD> <TD> g++: error: ***: No such file or directory </TD> </TR>
  <TR> <TD align="right"> 6 </TD> <TD> 連結期錯誤: 找不到定義 </TD> <TD> Symbol not found: __Z6error3v </TD> </TR>
  <TR> <TD align="right"> 7 </TD> <TD> 其他 </TD> <TD> ... </TD> </TR>
   </TABLE>


<br/>
一定要學習讀錯誤訊息

--- &vcenter .large

請嘗試歸類下列錯誤訊息的原因


```r
library(devtools)
install_github("RcppTutorial_Compiler", "wush978", 
               "gh-pages", subdir="RcppTutorialExercise1")
library(RcppTutorialExercise1)
ex1.1()
# ans1.1(1)
ex1.2()
# ans1.2(1)
ex1.3()
# ans1.3(1)
ex1.4()
# ans1.4(1)
ex1.5()
# ans1.5(1)
```

