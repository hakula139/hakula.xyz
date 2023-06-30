---
title: "编译 - Lab 2: PCAT 语法分析器"
date: 2021-12-07T02:16:00+08:00

tags: [编译, 语法分析, Bison, Flex, AST, PCAT, C++]
categories: [note]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/94538258.webp
license: CC BY-NC-SA 4.0
---

本项目利用 Bison 和 Flex，实现了对给定 PCAT 语言样例的语法分析。

Compilers @ Fudan University, fall 2021.

<!--more-->

{{< admonition info 封面出处 >}}
[紅葉から生まれた天の川 - @輪廻（りんね）](https://www.pixiv.net/artworks/94538258)
{{< /admonition >}}

{{< admonition success 源码地址 >}}
[:(fab fa-github):  hakula139 / pcat_parser](https://github.com/hakula139/pcat_parser)
{{< /admonition >}}

## 1 项目结构总览

- `bin/`：二进制文件的存放位置（构建时自动生成）
  - `parser`：本 PCAT 语法分析器的二进制文件
- `build/`：构建过程中产生的临时文件的存放位置（构建时自动生成）
- `docs/`：一些文档
  - `report.md`：本项目报告
- `lib/`：一些项目依赖
  - `bison-3.8.2.tar.gz`：Bison 3.8.2 的源码包[^bison-tgz]
- `output/`：对测试样例的语法分析结果（运行后自动生成）
- `scripts/`：一些自动化脚本
  - `prebuild.sh`：项目依赖的自动化安装脚本[^bison-tgz]
  - `test.sh`：自动化测试脚本，对 `tests/` 目录下的 PCAT 代码文件进行语法分析，并将分析结果保存在 `output/` 目录下
- `src/`：项目源代码
  - `ast/`：抽象语法树（Abstract Syntax Tree, AST）的节点定义
    - `body.hpp`：body
    - `body.cpp`
    - `constant.hpp`：integer, real, number, string
    - `constant.cpp`
    - `decl.hpp`：declaration
    - `decl.cpp`
    - `expr.hpp`：expression
    - `expr.cpp`
    - `identifier.hpp`：identifier
    - `lvalue.hpp`：lvalue
    - `lvalue.cpp`
    - `node.hpp`：node，所有节点的基类
    - `node.cpp`
    - `operator.hpp`：operator
    - `param.hpp`：parameters
    - `param.cpp`
    - `program.hpp`：program
    - `program.cpp`
    - `stmt.hpp`：statement
    - `stmt.cpp`
    - `type.hpp`：type
    - `type.cpp`
    - `index.hpp`：include 了所有 AST 的头文件，方便其他文件导入
  - `base/`：一些通用的头文件
    - `common.hpp`：一些可复用代码
    - `config.hpp`：一些项目设置
  - `utils/`：一些工具类函数
    - `logger.hpp`：日志记录器，也用于语法分析时的报错
    - `logger.cpp`
  - `driver.hpp`：语法分析器
  - `driver.cpp`
  - `lexer.hpp`：词法分析器的头文件
  - `lexer.lex`：词法分析器的 Lex 文件，用于 Flex 生成词法分析器的源文件
  - `lexer.cpp`：词法分析器的源文件（构建时自动生成）
  - `location.hpp`：语法分析器 location 的头文件，用于标识当前分析到的位置（构建时自动生成）
  - `main.cpp`：主程序入口
  - `parser.yy`：语法分析器的 Yacc 文件，用于 Bison 生成语法分析器的头文件、源文件和 `location.hpp`
  - `parser.hpp`：语法分析器的头文件（构建时自动生成）
  - `parser.cpp`：语法分析器的源文件（构建时自动生成）
- `tests/`：用于测试的 PCAT 代码文件的存放位置
- `.clang-format`：用于 Clang-Format 进行代码格式化的配置文件
- `Makefile`：用于 Make 进行构建的项目描述文件
- `README.md`：一个简单的说明文档

[^bison-tgz]: 有些操作系统自带的 Bison 版本较老，无法运行本项目，因此这里提供了 Bison 3.8.2 的源码供编译使用，可执行 `scripts/prebuild.sh` 进行自动化安装。

## 2 运行本项目

### 2.1 构建与运行

本项目使用 C++17 编写，构建前需要先安装以下依赖：

- [GCC][gcc] 9.0 或以上（以支持 C++17 特性）
- [GNU Make][make] 4.0 或以上
- [Flex][flex] 2.6.4（其他版本未测试）
- [GNU Bison][bison] 3.8[^bison-ver]

执行 `make` 即可构建本项目。运行项目时，执行 `make INPUT=<path>` 以读取文件，其中 `<path>` 即为指定的文件路径。例如：

```bash
make INPUT="tests/case_1.pcat"
```

输出文件将默认保存在 `output` 目录下。

[gcc]: https://gcc.gnu.org/releases.html
[make]: https://www.gnu.org/software/make
[flex]: https://github.com/westes/flex
[bison]: https://www.gnu.org/software/bison

[^bison-ver]: 更低版本确定不可用。暂时没有更高版本，但根据文档，Bison 的 C++ API 未来随时会改，因此不保证向上兼容性。

### 2.2 测试

本项目自带了 14 个 PCAT 语言测试样例，位于 `tests` 目录下。测试时依次通过上述命令处理即可，或者你也可以使用我们提供的自动化测试脚本 `scripts/test.sh`。

例如对于这样的输入（`tests/case_1.pcat`）：

```pcat
PROGRAM IS
    VAR i, j : INTEGER := 1; 
    VAR x : REAL := 2.0;
    VAR y : REAL := 3.0;
BEGIN 
    WRITE ("i = ", i, ", j = ", j);
    WRITE ("x = ", x, ", y = ", y);
END;
```

就将得到这样的输出：

```text
# tests/case_1.pcat


program <1:1-8:5>
  body <1:11-8:4>
    declaration list <1:11-4:25>
      variable declaration <2:9-2:29>
        identifier list <2:9-2:13>
          identifier <2:9-2:10> i
          identifier <2:12-2:13> j
        type annotation <2:14-2:23>
          identifier type <2:16-2:23>
            identifier <2:16-2:23> INTEGER
        number expression <2:27-2:28> 1
          integer <2:27-2:28> 1
      variable declaration <3:9-3:25>
        identifier list <3:9-3:10>
          identifier <3:9-3:10> x
        type annotation <3:11-3:17>
          identifier type <3:13-3:17>
            identifier <3:13-3:17> REAL
        number expression <3:21-3:24> 2.0
          real <3:21-3:24> 2.0
      variable declaration <4:9-4:25>
        identifier list <4:9-4:10>
          identifier <4:9-4:10> y
        type annotation <4:11-4:17>
          identifier type <4:13-4:17>
            identifier <4:13-4:17> REAL
        number expression <4:21-4:24> 3.0
          real <4:21-4:24> 3.0
    statement list <5:6-7:36>
      write statement <6:5-6:36>
        write parameter list <6:12-6:34>
          write expression <6:12-6:18> "i = "
            string <6:12-6:18> "i = "
          write expression <6:20-6:21> i
            lvalue expression <6:20-6:21> i
              lvalue <6:20-6:21> i
          write expression <6:23-6:31> ", j = "
            string <6:23-6:31> ", j = "
          write expression <6:33-6:34> j
            lvalue expression <6:33-6:34> j
              lvalue <6:33-6:34> j
      write statement <7:5-7:36>
        write parameter list <7:12-7:34>
          write expression <7:12-7:18> "x = "
            string <7:12-7:18> "x = "
          write expression <7:20-7:21> x
            lvalue expression <7:20-7:21> x
              lvalue <7:20-7:21> x
          write expression <7:23-7:31> ", y = "
            string <7:23-7:31> ", y = "
          write expression <7:33-7:34> y
            lvalue expression <7:33-7:34> y
              lvalue <7:33-7:34> y
```

## 3 Makefile 文件说明

下面我们通过 Makefile，简单介绍一下项目的构建顺序。

首先，我们通过此 recipe 利用 Flex 生成词法分析器的源文件 `lexer.cpp`。

```makefile
SRC_DIR   := src

LEX_IN    := $(SRC_DIR)/lexer.lex
LEX_SRC   := $(SRC_DIR)/lexer.cpp
LEX       := flex

$(LEX_SRC): $(LEX_IN)
	@echo + $@
	@$(LEX) -o $@ $<
```

随后，我们通过此 recipe 利用 Bison 生成语法分析器的头文件 `parser.hpp`、源文件 `parser.cpp` 和 location 的头文件 `location.hpp`。

```makefile
YACC_IN   := $(SRC_DIR)/parser.yy
YACC_SRC  := $(SRC_DIR)/parser.cpp
YACC_H    := $(SRC_DIR)/parser.hpp $(SRC_DIR)/location.hpp
YACC      := bison

$(YACC_SRC): $(YACC_IN)
	@echo + $@
	@$(YACC) -o $@ -d $<

$(YACC_H): $(YACC_SRC)
```

然后，我们通过此 recipe 利用 g++ 生成各源文件的目标文件（`.o`）。这里我们通过 `-MMD` 参数，在编译的同时生成相应的依赖信息文件（`.d`），用于 Make 理解文件之间的依赖关系，避免手写繁琐的依赖规则。

```makefile
BUILD_DIR := build

CXX       := g++
CXXFLAGS  := -g -Wall -O3 -std=c++17 -MMD
MKDIR     := mkdir -p

$(BUILD_DIR)/%.cpp.o: %.cpp
	@echo + $@
	@$(MKDIR) $(dir $@)
	@$(CXX) $(CXXFLAGS) -c -o $@ $<
```

最后，我们通过此 recipe 利用 g++ 生成最终的二进制文件 `bin/parser`。这里我们利用 shell 命令递归查找 `src` 目录下的所有 `.cpp` 文件，避免在 Makefile 里硬编码所有的文件名。

```makefile
TARGET    := parser
BIN_DIR   := bin

SRCS      := $(YACC_SRC) $(LEX_SRC) $(shell find $(SRC_DIR) -name *.cpp)
OBJS      := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS      := $(OBJS:.o=.d)

$(BIN_DIR)/$(TARGET): $(OBJS)
	@echo + $@
	@$(MKDIR) $(dir $@)
	@$(CXX) $(CXXFLAGS) -o $@ $^

# ...

-include $(DEPS)
```

运行项目时，我们通过默认 recipe（顺序位于第一个）执行二进制文件 `bin/parser`。这里变量 `INPUT` 需要用户通过参数传入，作为读取的文件路径。

```makefile
OUT_DIR   := output

start: $(BIN_DIR)/$(TARGET)
	@$(MKDIR) $(OUT_DIR)
	@$< $(INPUT)
```

需要清理项目时，执行 `make clean` 即可通过此 recipe 清除所有构建过程中生成的文件。

```makefile
RM        := rm -rf

clean:
	@$(RM) $(BIN_DIR) $(BUILD_DIR) $(LEX_SRC) $(YACC_SRC) $(YACC_H)
```

完整的 Makefile 可以参见项目根目录下的 [`Makefile`][makefile] 文件。

[makefile]: https://github.com/hakula139/pcat_parser/blob/master/Makefile

## 4 Bison 使用方法

Bison 文件的结构和 Flex 文件类似，总体分为四个部分[^bison-3.1]：

- Prologue：定义了一些 Bison 头文件和源文件中需要使用的函数和变量，一般通过 include 外部宏的方式实现。
- Bison declarations：声明了所有终结符和非终结符以及它们语义值的类型，同时指定了一些操作符的优先级。此外这里也包含了 Bison 的各种设置。
- Grammar rules：定义了语法分析的具体规则，即每个非终结符有哪些产生式，匹配到相应产生式时需要采取什么操作等等。
- Epilogue：用户可以在这里定义一些辅助函数，此部分代码会被直接复制到 `src/parser.cpp` 里。

```cpp
%{
// Prologue
%}

// Bison declarations

%%
// Grammar rules
%%

// Epilogue
```

其中，Prologue 部分也可以有其他一些替代形式。本项目中利用到的为如下两种：

```cpp
%code requires {
// Prologue
}
```

此部分代码将被直接复制到 `src/parser.hpp` 的头部，通常包含在语法分析器的头文件里就需要用到的声明，例如所有终结符和非终结符的类型声明。

```cpp
%code top {
// Prologue
}
```

此部分代码将被直接复制到 `src/parser.cpp` 的头部，包含语法分析器的实现里需要用到的声明。

下面我们展开讲讲本项目中这四个部分的具体内容。

[bison-3.1]: https://www.gnu.org/software/bison/manual/html_node/Grammar-Outline.html

[^bison-3.1]: 参见 Bison 文档的 [3.1][bison-3.1] 节。

### 4.1 Prologue

```cpp
// src/parser.yy

%code requires {
#include <string>

#include "ast/index.hpp"
#include "base/common.hpp"

class Driver;
namespace yy {
  class Lexer;
}
}
```

我们首先在语法分析器的头文件里 include 了 `<string>` 和 `ast/index.hpp`，前者是所有终结符的语义值类型 `std::string`，后者声明了所有非终结符的语义值类型（AST 节点）。随后我们 include 了 `base/common.hpp`，这里主要是用到了其中对 `std::shared_ptr` 的缩写 `SPtr`。

```cpp
// src/parser.yy

%code top {
#include <memory>   // std::make_shared

#include "driver.hpp"
#include "lexer.hpp"
#include "utils/logger.hpp"

using std::make_shared;
using location_type = yy::Parser::location_type;
using symbol_type = yy::Parser::symbol_type;

static symbol_type yylex(yy::Lexer* p_lexer) {
  return p_lexer->ReadToken();
}

// A workaround to solve the undefined reference issue, as we have defined
// another yylex() which is not default.
int yyFlexLexer::yylex() {
  Logger::Warn("calling wrong yylex()");
  return EXIT_FAILURE;
}
}
```

然后，我们在语法分析器的源代码里提供了函数 `yy::Parser::yylex()` 的定义，在 Parser 调用 Lexer 读取 token 时需要使用。这里这样写的目的是为了修改 Flex 提供的函数 `yylex()` 的默认函数签名 `int yyFlexLexer::yylex()`，因为 Bison 要求函数 `yylex()` 的返回值是一个 `symbol_type` 而不是 `int`，但普通的函数重载最多只能修改传入的参数，而不能修改返回值的类型。这里仍然提供了一个 `int yyFlexLexer::yylex()` 的定义，否则编译时会报错。

此外，为了修改这个返回值的类型，我们还需要在 `src/lexer.hpp` 里定义宏 `YY_DECL`：

```cpp
// src/lexer.hpp

// Override the default yylex() to return a symbol_type instead of int.
#define YY_DECL yy::Parser::symbol_type yy::Lexer::ReadToken()
```

这样 Flex 在生成 `yylex()` 的代码时，就会以这个为实际的函数签名。

流程上，Parser 在读取 token 时，会先调用自己的 `yy::Parser::yylex()`（无法修改），这个函数我们已经提供了定义，其中传入的参数是由设置 `%lex-param` 决定的，接下来我们会提到。然后这个函数会调用 `yy::Lexer::ReadToken()`，其中 `yy::Lexer` 是我们自己定义的类，代码如下所示，主要目的是为了给 `yyFlexLexer` 提供一个额外的私有成员 `Driver& drv_`，在词法分析时需要用到。这里 `yy::Lexer::ReadToken()` 我们只提供声明（通过定义宏 `YY_DECL` 的方式），而函数定义则由 Flex 自动生成。最后 `yy::Lexer::ReadToken()` 就会以 Flex 自动生成的原本 `yyFlexLexer::yylex()` 的实现为我们读取下一个 token，而原来的 `int yyFlexLexer::yylex()` 则不会再被调用（但仍需提供定义，理论上这应该是 Flex 的 bug）。当然，为此我们还需要调整词法分析器的源代码，通过 Bison 的接口令 `yy::Lexer::ReadToken()` 在实现里返回的值不是 `int` 而是 `symbol_type`，这个我们 [之后](#52-token-类型) 再讲。

```cpp
// src/lexer.hpp

namespace yy {
class Lexer : public yyFlexLexer {
 public:
  explicit Lexer(Driver* p_drv) : drv_{*p_drv} {}

  virtual Parser::symbol_type ReadToken();

 private:
  Driver& drv_;
};
}  // namespace yy
```

是不是绕了很大一个弯子？主要原因是 Bison 和 Flex 的接口很多都写死了。为了实现交互，只能用这种比较 dirty 的办法了。尽管不一定是唯一的方式，但应该是目前最好的方式。

### 4.2 Bison declaration

接下来，我们需要对 Bison 进行一些设置，具体含义见注释。

```cpp
// src/parser.yy

%skeleton "lalr1.cc"      // 使用 LALR1 语法分析器
%require "3.8"            // 指定 Bison 版本为 3.8+（部分特性仅 3.8+ 支持）
%header "src/parser.hpp"  // 生成 Parser 时将头文件分离，并将 Parser 的头文件保存在这个路径
%locations                // 提供 location 接口，以便 Lexer 记录当前分析到的位置

%define api.parser.class {Parser}         // 指定生成 Parser 的类名为 Parser
%define api.location.file "location.hpp"  // 将 location 的头文件保存在这个路径（相对于 parser.hpp 位置）
%define api.token.constructor             // 提供 token 构造函数接口，以便 Lexer 返回 symbol_type 的 token
%define api.token.prefix {T_}             // 为 token 名增加指定前缀
%define api.token.raw                     // 因为 Lexer 返回的已经是 symbol_type 的 token 而非读取的原字符，
                                          // 这里不再需要转换
%define api.value.type variant            // 指定 token 语义值类型为 variant，用于同时支持更广泛的类型，
                                          // 参见 C++17 的 std::variant

%define parse.assert         // 通过运行时检查确保 token 被正常构造与析构，以保证上述 variant 类型被正确使用
%define parse.trace          // 启用 Debug 功能
%define parse.error verbose  // 指定报错等级，verbose 级别将对语法分析时遇到的错误进行详细报错
%define parse.lac full       // 启用 lookahead correction (LAC)，提高对语法错误的处理能力

%lex-param {yy::Lexer* p_lexer}                       // 函数 yy::Parser::yylex() 传入的参数
%parse-param {yy::Lexer* p_lexer} {Driver* p_driver}  // 函数 yy::Parser::Parser() 传入的参数
```

对这些设置的详尽解释建议直接参考官方文档[^bison-3.7]。

然后，我们需要声明语法分析时遇到的所有终结符和非终结符的语义值类型。其中 `%token` 表示终结符，`%nterm` 表示非终结符。

```cpp
// src/parser.yy

%token
  // Reserved keywords
  <std::string>       AND
  <std::string>       ARRAY
  <std::string>       BEGIN
  <std::string>       BY
  <std::string>       DIV
  <std::string>       DO
  <std::string>       ELSE
  <std::string>       ELSIF
  <std::string>       END
  <std::string>       EXIT
  <std::string>       FOR
  <std::string>       IF
  <std::string>       IN
  <std::string>       IS
  <std::string>       LOOP
  <std::string>       MOD
  <std::string>       NOT
  <std::string>       OF
  <std::string>       OR
  <std::string>       OUT
  <std::string>       PROCEDURE
  <std::string>       PROGRAM
  <std::string>       READ
  <std::string>       RECORD
  <std::string>       RETURN
  <std::string>       THEN
  <std::string>       TO
  <std::string>       TYPE
  <std::string>       VAR
  <std::string>       WHILE
  <std::string>       WRITE

  // Operators
  <std::string>       ASSIGN              ":="
  <std::string>       PLUS                "+"
  <std::string>       MINUS               "-"
  <std::string>       STAR                "*"
  <std::string>       SLASH               "/"
  <std::string>       LT                  "<"
  <std::string>       LE                  "<="
  <std::string>       GT                  ">"
  <std::string>       GE                  ">="
  <std::string>       EQ                  "="
  <std::string>       NE                  "<>"

  // Delimiters
  <std::string>       COLON               ":"
  <std::string>       SEMICOLON           ";"
  <std::string>       COMMA               ","
  <std::string>       DOT                 "."
  <std::string>       LPAREN              "("
  <std::string>       RPAREN              ")"
  <std::string>       LSBRAC              "["
  <std::string>       RSBRAC              "]"
  <std::string>       LCBRAC              "{"
  <std::string>       RCBRAC              "}"
  <std::string>       LSABRAC             "[<"
  <std::string>       RSABRAC             ">]"
  <std::string>       BACKSLASH           "\\"

  // Constants
  <std::string>       INTEGER             "integer"
  <std::string>       REAL                "real"
  <std::string>       STRING              "string"

  // Identifiers
  <std::string>       ID                  "identifier"
;
```

这里 `INTEGER` 和 `REAL` 的类型分别设置为 `int32_t` 和 `double` 也是可以的，真正做语法分析时应该这样设置。这里设置成 `std::string` 单纯是为了输出语法树时能保留原来的格式，例如值为 $2.0$ 的 `REAL` 应输出为 $2.0$ 而不是 $2$。

```cpp
// src/parser.yy

%nterm
  // Programs
  <SPtr<Program>>             program
  <SPtr<Body>>                body

  // Declarations
  <SPtr<Decls>>               decls
  <SPtr<Decls>>               decl           // 不是 typo，就是 Decls 类型，因为一个 decl 可以包含多个
                                             // var_decls / type_decls / proc_decls
  <SPtr<VarDecls>>            var_decls
  <SPtr<VarDecl>>             var_decl
  <SPtr<TypeDecls>>           type_decls
  <SPtr<TypeDecl>>            type_decl
  <SPtr<ProcDecls>>           proc_decls
  <SPtr<ProcDecl>>            proc_decl
  <SPtr<FormalParams>>        formal_params
  <SPtr<FormalParam>>         formal_param
  <SPtr<TypeAnnot>>           type_annot
  <SPtr<Type>>                type
  <SPtr<Components>>          components
  <SPtr<Component>>           component
  <SPtr<Ids>>                 ids
  <SPtr<Id>>                  id

  // Statements
  <SPtr<Stmts>>               stmts
  <SPtr<Stmt>>                stmt
  <SPtr<ActualParams>>        actual_params
  <SPtr<ReadParams>>          read_params
  <SPtr<WriteParams>>         write_params
  <SPtr<ElifSections>>        elif_sections
  <SPtr<ElifSection>>         elif_section
  <SPtr<ElseSection>>         else_section
  <SPtr<ForStep>>             for_step

  // Expressions
  <SPtr<Exprs>>               exprs
  <SPtr<Expr>>                expr
  <SPtr<WriteExprs>>          write_exprs
  <SPtr<WriteExpr>>           write_expr
  <SPtr<AssignExprs>>         assign_exprs
  <SPtr<AssignExpr>>          assign_expr
  <SPtr<ArrayExprs>>          array_exprs
  <SPtr<ArrayExpr>>           array_expr
  <SPtr<Number>>              number
  <SPtr<Integer>>             integer
  <SPtr<Real>>                real
  <SPtr<String>>              string
  <SPtr<Lvalues>>             lvalues
  <SPtr<Lvalue>>              lvalue
  <SPtr<CompValues>>          comp_values
  <SPtr<ArrayValues>>         array_values
;
```

可以看到对所有的非终结符，我们都定义了一个 AST 节点，每个非终结符的类型就是这个节点的 `std::shared_ptr`。为什么使用 `std::shared_ptr` 而不是普通指针？因为这样就不需要手动管理内存了，否则析构时需要释放以当前节点为根的子树的所有节点，关键是报错（抛异常）时要记得释放，这点比较复杂。为什么不使用 `std::unique_ptr`？其实语义上用 `std::unique_ptr` 是对的，因为所有节点都是唯一的。事实上我一开始也用的是 `std::unique_ptr`，但能力有限，花了两整天的时间也没能解决所有权转移时的各种问题，最后还是放弃了。`std::shared_ptr` 由于可以进行拷贝构造，相对要省心太多，而且增加的额外性能开销其实也可以接受。我们毕竟只是一个 toy project，还不至于需要抠 `std::unique_ptr` 和 `std::shared_ptr` 的这点性能差距。

需要注意的是，我们对终结符 `INTEGER`, `REAL`, `STRING` 还额外封装了三个对应的非终结符，这个主要是为了书写规则时的形式统一，不定义这几个非终结符也是可以的。

此外，我们还需要指定操作符的优先级和结合性。从上到下表示优先级依次提高，`%left`, `%right`, `%nonassoc` 分别表示左结合、右结合和非结合。这里我们额外定义了两个假的操作符 `POS` 和 `NEG`，分别对应作为单目运算符时的 `PLUS` 和 `MINUS`。这个假操作符占位操作将在 [之后](#43-grammar-rules) 通过 `%prec` 显式指定优先级时利用到。

```cpp
// src/parser.yy

%left                 OR;
%left                 AND;
%nonassoc             EQ NE;
%nonassoc             LT LE GT GE;
%left                 PLUS MINUS;
%left                 STAR SLASH DIV MOD;
%right                POS NEG NOT;
```

[bison-3.7]: https://www.gnu.org/software/bison/manual/html_node/Declarations.html

[^bison-3.7]: 参见 Bison 文档的 [3.7][bison-3.7] 节。

### 4.3 Grammar rules

那么接下来就是定义语法分析的具体规则了，也就是定义所有非终结符的产生式。由于数量较多，这里我们针对一些比较有代表性的规则进行详解。

首先讲一下 Bison 里产生规则的格式：

```cpp
result:
  rule1-components { /* action1 */ }
| rule2-components { /* action2 */ }
;
```

其中 `result` 表示产生的非终结符，`rule1-components` 和 `rule2-components` 表示两种可以产生 `result` 的终结符 / 非终结符组合方式，`action1` 和 `action2` 表示每次匹配到相应产生式时需要执行的动作。

下面我们来看一些实例。

```cpp
// src/parser.yy

%start program;

// Programs

program:
  PROGRAM IS body SEMICOLON {
    $$ = make_shared<Program>(@$, $body);
    p_driver->set_program($$);
  }
;
```

首先是程序的根结点 `program`。我们知道 `program` 的产生式如下[^pcat-12]：

```text
program -> PROGRAM IS body ';'
```

由于我们已经定义了 `;` 的 token 为 `SEMICOLON`，在产生规则里我们可以用 `SEMICOLON` 代替。

在规则对应的动作里，我们利用 `std::make_shared` 直接构造一个指向 `Program` 类的 `std::shared_ptr`，构造函数传入的参数为 `@$` 和 `$body`，分别表示 `$` 当前的 location 和 `body` 的语义值，其中 `$` 表示当前非终结符（也就是 `program`）。最后我们将这个指针赋值给 `$$`，也就是 `$` 的语义值。

由于 `$` 是根结点 `program`，因此我们将其保存到 `Driver` 类里。将来我们通过 `Driver` 打印语法树时，这就是我们语法树的根。

之后我会在 [7](#7-语法树实现) 节详细讲解这里发生了什么，现在我们只需要知道，每个非终结符 `x` 的语义值就是一个指向这个 AST 节点 `x` 的指针 `$x`。当构造一个节点 `x` 时，需要传入这个节点的位置 `@x` 和其子节点的语义值 `$y`，其中子节点即构成这个非终结符的所有非终结符和**有值**的终结符（`INTEGER`, `REAL`, `STRING`）。

举个复杂点的例子，比如 `stmt` 的产生规则就是：

```cpp
// src/parser.yy

stmt:
  lvalue ASSIGN expr SEMICOLON {
    $$ = make_shared<AssignStmt>(@$, $lvalue, $expr);
  }
| id LPAREN actual_params RPAREN SEMICOLON {
    $$ = make_shared<ProcCallStmt>(@$, $id, $actual_params);
  }
| READ LPAREN read_params RPAREN SEMICOLON {
    $$ = make_shared<ReadStmt>(@$, $read_params);
  }
| WRITE LPAREN write_params RPAREN SEMICOLON {
    $$ = make_shared<WriteStmt>(@$, $write_params);
  }
| IF expr THEN stmts elif_sections[elif] else_section[else] END SEMICOLON {
    $$ = make_shared<IfStmt>(@$, $expr, $stmts, $elif, $else);
  }
| WHILE expr DO stmts END SEMICOLON {
    $$ = make_shared<WhileStmt>(@$, $expr, $stmts);
  }
| LOOP stmts END SEMICOLON {
    $$ = make_shared<LoopStmt>(@$, $stmts);
  }
| FOR id ASSIGN expr[begin] TO expr[end] for_step[step] DO stmts END SEMICOLON {
    $$ = make_shared<ForStmt>(@$, $id, $begin, $end, $step, $stmts);
  }
| EXIT SEMICOLON {
    $$ = make_shared<ExitStmt>(@$);
  }
| RETURN SEMICOLON {
    $$ = make_shared<ReturnStmt>(@$);
  }
| RETURN expr SEMICOLON {
    $$ = make_shared<ReturnStmt>(@$, $expr);
  }
;
```

其中 `nterm[alias]` 表示为这个 `nterm` 取别名 `alias`。

注意到 `$$` 在不同的产生式里可以有不同的类型，这主要是利用了 C++ 的多态性。在实现 AST 时，我们利用继承实现了多态。例如此处 `AssignStmt`, `ProcCallStmt` 等等都是以 `Stmt` 为基类的派生类，因此其指针可以直接赋值给基类指针，同时不失语义（利用虚函数，基类指针可以调用派生类的函数实现）。

再看一个例子，这个是 `expr` 的产生规则：

```cpp
// src/parser.yy

expr:
  number { $$ = make_shared<NumberExpr>(@$, $1); }
| lvalue { $$ = make_shared<LvalueExpr>(@$, $1); }
| LPAREN expr RPAREN { $$ = make_shared<ParenExpr>(@$, $2); }
| PLUS expr %prec POS { $$ = make_shared<UnaryExpr>(@$, make_shared<Op>(@1, $1), $2); }
| MINUS expr %prec NEG { $$ = make_shared<UnaryExpr>(@$, make_shared<Op>(@1, $1), $2); }
| NOT expr { $$ = make_shared<UnaryExpr>(@$, make_shared<Op>(@1, $1), $2); }
| expr PLUS expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr MINUS expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr STAR expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr SLASH expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr DIV expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr MOD expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr OR expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr AND expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr LT expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr LE expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr GT expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr GE expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr EQ expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| expr NE expr { $$ = make_shared<BinaryExpr>(@$, $1, make_shared<Op>(@2, $2), $3); }
| id LPAREN actual_params RPAREN { $$ = make_shared<ProcCallExpr>(@$, $1, $3); }
| id LCBRAC comp_values RCBRAC { $$ = make_shared<RecordConstrExpr>(@$, $1, $3); }
| id LSABRAC array_values RSABRAC { $$ = make_shared<ArrayConstrExpr>(@$, $1, $3); }
;
```

首先注意到，我们也可以用 `$1`, `$2` 来表示产生式右侧的第 1, 2 个符号。

这里为什么不能将 `UnaryExpr` 或 `BinaryExpr` 的产生式合并成一个 `op expr` 和 `expr op expr` 呢？是因为我们需要利用操作符 `op` 的优先级和结合性。如果我们将 `op` 提取出来，在产生式里仅保留一个非操作符 `op`，Bison 将无法利用终结符的优先级和结合性信息，从而导致错误的语法分析结果。

式中，`PLUS expr %prec POS` 表示对此式采用 `POS` 的优先级。[前面](#42-bison-declaration) 我们看到，`POS` 的优先级和 `NOT` 同级，通过这种方式我们就实现了对 `PLUS` 作为单目运算符时优先级的重定义。

除了这种单个节点的构造方式外，我们还存在另一种数组节点的构造方式。

```cpp
// src/parser.yy

elif_sections:
  %empty { $$ = make_shared<ElifSections>(@$); }
| elif_sections elif_section { $$ = $1; if ($$) $$->Insert($2); }
;
```

`elif_sections` 的产生式如下：

```text
elif_sections -> {elif_section}
```

表示 `elif_sections` 由多个 `elif_section` 构成。

在 Bison 的产生规则中，我们通过一种递归的方式来描述这个产生式。作为递归的退出条件，空产生式可以用 `%empty` 表示，其对应的动作是新建一个 `ElifSections` 对象。在 AST 节点的实现中，其本质是一个 `std::vector<std::shared_ptr<ElifSection>>`，也就是一个子节点指针的数组。之后每多分析到一个 `elif_section`，就往这个数组里插入一个子节点指针，并更新此节点的 location。这里 `Insert()` 函数会同时完成这两件事情。

此外，我们还提供了 `InsertArray()` 函数，用于转移另一个数组节点 `y` 的所有子节点到数组节点 `x`。适用于语义上不应当将 `y` 作为 `x` 的子节点的情形。例如：

```cpp
// src/parser.yy

decls:
  %empty { $$ = make_shared<Decls>(@$); }
| decls decl { $$ = $1; if ($$) $$->InsertArray($2); }
;

decl:
  VAR var_decls { $$ = $2; if ($$) $$->set_loc(@$); }
| PROCEDURE proc_decls { $$ = $2; if ($$) $$->set_loc(@$); }
| TYPE type_decls { $$ = $2; if ($$) $$->set_loc(@$); }
;
```

这里 `$$->set_loc(@$)` 的作用即更新当前节点的 location。需要注意的是，这里 `decls` 和 `decl` 的语义值类型均为 `std::shared_ptr<Decls>`。

其他规则基本上就大同小异了，这里不作赘述。具体代码可以参见 [`src/parser.yy`][parser.yy]。

[parser.yy]: https://github.com/hakula139/pcat_parser/blob/master/src/parser.yy

[^pcat-12]: 参见 [PCAT 标准文档][pcat] 的 12 节。

### 4.4 Epilogue

最后我们在 Epilogue 给出了函数 `yy::Parser::error()` 的实现，用于语法分析器的报错实现。

```cpp
// src/parser.yy

void yy::Parser::error(const location_type& loc, const std::string& msg) {
  Logger::Error(msg, &loc);
  Logger::Error(msg, &loc, p_driver->ofs());
}
```

流程上，当 Lexer 或 Parser 遇到词法错误或语法错误时，就会抛出一个 `std::syntax_error` 异常。程序捕获这个异常后，就会调用函数 `yy::Parser::error()`，然后调用函数 `Logger::Error()`，并传入参数 `loc` 和 `msg`，分别对应错误发生的位置和错误信息。

函数 `Logger::Error()` 的实现很简单，本质就是对 `operator<<()` 的一个封装。

```cpp
// src/utils/logger.cpp

void Logger::Log(
    const std::string& msg, const yy::location* p_loc, std::ostream& os) {
  if (p_loc) {
    auto loc = *p_loc;
    os << loc.begin.line << ":" << loc.begin.column << "-" << loc.end.line
       << ":" << loc.end.column << ": ";
  }
  os << msg;
  if (&os == &std::cout) os << RESET;
  os << "\n";
}

void Logger::Error(
    const std::string& msg, const yy::location* p_loc, std::ostream& os) {
  if (LOG_LEVEL <= ERROR) {
    if (&os == &std::cout) os << RED;
    os << "[ERROR] ";
    Log(msg, p_loc, os);
  }
}
```

这里利用 ANSI 字符颜色转义序列美化了下日志输出，给报错信息加了个颜色。

```cpp
// src/base/common.cpp

// ANSI colors
#define RED "\e[0;31m"
#define RESET "\e[0;0m"
```

## 5 对 Flex 文件的修改

由于现在我们使用 Bison 进行语法分析，在接入 Flex 作为词法分析器时，需要做一定的调整。

### 5.1 位置追踪

在之前的实现中，我们基本是手动维护的位置信息。现在 Bison 提供了十分强大的 location 接口，我们自然也要利用起来。

具体来说，我们需要定义宏 `YY_USER_ACTION`。

```cpp
// src/lexer.lex

%{
#define YY_USER_ACTION loc.step(); loc += YYLeng();
%}

%%

%{
  auto& loc = drv_.loc();
%}
```

`YY_USER_ACTION` 将在每次 Lexer 读取一个 token 后执行一次。其中 `loc.step()` 将当前 `loc` 的 `begin` 设置为 `end`，`loc += YYLeng()` 将当前 `loc` 的 `end.column` 增加当前 token 的长度。于是，我们就得到了当前 token 的始末位置。这里 `drv_` 就是 [之前](#41-prologue) 提到的 `Lexer` 在继承 `yyFlexLexer` 时保存的额外私有成员 `Driver& drv_`。

对于换行的情况，我们在遇到换行符 `\n` 时利用 `loc.lines()` 将当前 `loc` 的 `end.line` 加 1，`end.column` 设置为 1，从而实现了行号的更新。

```cpp
// src/lexer.lex

NEWLINE               \n

%%

<INITIAL>{NEWLINE}            { loc.lines(); }
```

对于多行注释也是类似的处理。

```cpp
// src/lexer.lex

<COMMENT>{NEWLINE}            { loc.lines(); skip_COMMENTS(YYText(), loc); }
```

这里函数 `skip_COMMENTS()` 主要是为了保存注释内容用的。如果你不打算报错（unterminated comments）时在错误信息里打印注释内容，就没必要定义这个函数，直接跳过注释就可以了。

```cpp
// src/lexer.lex

void skip_COMMENTS(const std::string& s, const location_type& loc) {
  static std::string comments_buf;
  static location_type comments_loc;

  if (s == "(*") {
    comments_buf = s;
    comments_loc = loc;
  } else if (!s.empty()) {
    comments_buf += s;
    comments_loc += loc;
  } else {
    throw yy::Parser::syntax_error(
        comments_loc, "syntax error, unterminated comments: " + comments_buf);
  }
}
```

### 5.2 Token 类型

此外，[之前](#41-prologue) 我们提到 Lexer 现在需要返回一个 `symbol_type` 而不是 `int`，这部分逻辑我们是通过 Bison 的 token constructor 接口实现的。具体来说，原本我们是以枚举的形式定义所有的 token 类型：

```cpp
// https://github.com/hakula139/pcat_lexical_analyzer/blob/master/src/lexer.hpp

enum Tokens {
  T_EOF = 0,
  T_WS,
  T_NEWLINE,
  T_INTEGER,
  T_REAL,
  T_STRING,
  T_RESERVED,
  T_IDENTIFIER,
  T_OPERATOR,
  T_DELIMITER,
  T_COMMENTS_BEGIN,
  T_COMMENTS,
  T_COMMENTS_END,
};
```

现在则是调用 Bison 自动生成的函数 `yy::Parser::make_<TOKEN>()` 实现，传入的参数是 token 的语义值和位置。这个函数将为我们生成正确的 `symbol_type`，并会进行类型检查。例如：

```cpp
// src/lexer.lex

DIGIT                 [0-9]
REAL                  ({DIGIT}+"."{DIGIT}*)

%%

<INITIAL>{REAL}               { return yy::Parser::make_REAL(YYText(), loc); }
```

这里 `YYText()` 返回的就是 Lexer 读取到的 token 字符串。因为我们之前定义的 `REAL` 的语义值类型就是 `std::string`，所以这里不需要进行转换。如果定义的类型是 `double`，则需要通过 `std::stod()` 转换。如果 token 没有定义类型，则不需要传入这个参数。`loc` 就是我们维护的 token 始末位置。

关于如何实现词法错误的报错，我们将在下个章节统一讲解。得益于 Bison 的异常捕获机制，这次我们采取了和之前不同的报错实现方式。

## 6 错误检测与报错

Bison 的错误处理是通过捕获 `yy::Parser::syntax_error` 异常来实现的，这里 `yy::Parser::syntax_error` 是基于 `std::runtime_error` 的一个派生类。当分析过程中出现语法错误时，程序就会抛出一个 `yy::Parser::syntax_error` 异常，Bison 捕获后调用 `yy::Parser::error()` 函数进行报错。这个函数我们已经在 `src/parser.yy` 的 Epilogue 部分提供了定义。

### 6.1 词法错误

我们可以利用这个机制，让 Bison 对词法错误进行同样的错误处理。方法就是在 Flex 检测到词法错误时，同样抛出一个 `yy::Parser::syntax_error` 异常。具体来说，例如对于 `INTEGER` 的词法错误检测，我们可以这样实现：

```cpp
// src/lexer.lex

%{
symbol_type make_INTEGER(const std::string& s, const location_type& loc);
}%

DIGIT                 [0-9]
INTEGER               ({DIGIT}+)

%%

<INITIAL>{INTEGER}            { return make_INTEGER(YYText(), loc); }

%%

symbol_type make_INTEGER(const std::string& s, const location_type& loc) {
  try {
    std::stoi(s);
  } catch (const std::out_of_range& e) {
    throw yy::Parser::syntax_error(loc, "range error, integer out of range: " + s);
  }
  return yy::Parser::make_INTEGER(s, loc);
}
```

这里我们自定义了一个 `make_INTEGER()` 函数，用于在返回 token 前额外进行一些错误检测。具体的检测方法和之前基本一致，区别在于遇到词法错误时，这次我们直接抛出一个 `yy::Parser::syntax_error` 异常，传入的参数是 token 的位置和报错信息。这样我们就实现了对 Bison 语法错误处理机制的复用。

对于直接的词法错误也是类似的处理：

```cpp
// src/lexer.lex

%{
void panic_UNTERM_STRING(const std::string& s, const location_type& loc);
}%

UNTERM_STRING         (\"[^\n"]*)

%%

<INITIAL>{UNTERM_STRING}      { panic_UNTERM_STRING(YYText(), loc); }

%%

void panic_UNTERM_STRING(const std::string& s, const location_type& loc) {
  throw yy::Parser::syntax_error(
      loc, "syntax error, unterminated string literal: " + s);
}
```

### 6.2 语法错误

当 Bison 遇到语法错误时，会自动抛出 `yy::Parser::syntax_error` 异常，因此不需要我们显式地写报错逻辑，只需要定义 `yy::Parser::error()` 函数。

这里的难点其实不在报错，而在于错误恢复。一方面，如果我们不进行错误恢复，Bison 会在遇到第一处语法错误后直接退出程序，我们当然希望程序能尽可能一次性报告所有错误。另一方面，如果我们只是简单地在根节点处加上错误恢复逻辑，那就会产生很多不必要的报错信息，无法做到对错误的精确定位。因此，我们有必要 case by case 地对非终结符编写错误恢复逻辑。

然而，为每个非终结符的每个产生式都编写完善的错误恢复逻辑是非常困难且耗时的。由于时间有限，这里我们只针对测试样例编写了必要的错误恢复逻辑，仅确保对测试样例可以进行正确、精准的报错。当然，对测试样例以外的代码程序也会进行「正确」的报错，只是会产生不必要的报错信息。例如一行代码末尾少一个分号，导致包括这行代码在内的之后所有代码全部报错。

由于样例 `tests/case_11.pcat` 不是一个完整的程序，其重点在于对词法错误处理进行测试，为了让报错信息尽可能简明直观，这里对 `program` 的错误恢复逻辑做了一定的特判。

下面我们来看一些具体的例子：

```cpp
// src/parser.yy

program:
  PROGRAM IS body SEMICOLON {
    $$ = make_shared<Program>(@$, $body);
    p_driver->set_program($$);
  }
| error body SEMICOLON {
    $$ = make_shared<Program>(@$, $body);
    p_driver->set_program($$);
    yyerrok;
  }
| error { $$ = nullptr; yyerrok; yyclearin; }
;
```

这里，`error body SEMICOLON` 将语法错误视作一个 token（`error`）。通过这样的产生式可以让程序检测到错误后，能继续对后续输入进行语法分析（相当于假装这里没有发生错误）。例如这里就是尝试按照 `body SEMICOLON` 分析之后的输入。

动作里的 `yyerrok` 表示立即报错，并继续进行语法分析。继续分析时，程序默认会重新分析这次读入的 lookahead token，但有时这会导致程序出现死循环，`yyclearin` 的作用就是丢弃这个 token，直接读取下一个 token，从而避免这种情形。这里 `error { $$ = nullptr; yyerrok; yyclearin; }` 就是之前提到的对 `tests/case_11.pcat` 的特判。

```cpp
// src/parser.yy

var_decl:
  ids type_annot ASSIGN expr SEMICOLON {
    $$ = make_shared<VarDecl>(@$, $ids, $type_annot, $expr);
  }
| error SEMICOLON { $$ = nullptr; yyerrok; }
;
```

像这个错误恢复逻辑就很典型，就是当一条 `var_decl` 语句的结尾少一个分号时，舍弃接下来所有的 token，直到读到分号为止。读到分号后，错误恢复，继续进行接下来的语法分析。通常情况下，这样可以将一次错误造成的影响限制在尽量小的范围。

一些报错信息的样例展示（`tests/case_11.pcat`）如下，其中第一行是语法错误，其余行是词法错误：

```text
[ERROR] 2:1-2:9: syntax error, unexpected integer, expecting PROGRAM
[ERROR] 5:1-5:21: range error, integer out of range: 11111111111111111111
[ERROR] 14:1-14:10: value error, invalid character found in string: "abcde      g"
[ERROR] 17:1-17:12: value error, invalid character found in string: "abcde                      g"
[ERROR] 23:1-23:259: value error, string literal is too long: "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456"
[ERROR] 35:1-35:257: compile error, identifier is too long: x123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
[ERROR] 44:1-44:2: compile error, unknown character: 
[ERROR] 50:1-50:5: syntax error, unterminated string literal: "abc
[ERROR] 53:1-53:9: syntax error, unterminated string literal: "abc(**)
[ERROR] 56:1-56:12: syntax error, unterminated string literal: "abc(*123*)
[ERROR] 74:1-74:11: syntax error, unterminated comments: (****123**
```

## 7 语法树实现

接下来讲一下抽象语法树（AST）的实现，具体代码可以参见 [`src/ast`][ast] 目录下的文件。

我们将所有节点分为三种类型：节点 `Node`、有值节点 `ValueNode` 和数组节点 `Nodes`。我们先实现了节点的基类 `Node`，提供了节点的基本成员和方法，然后基于 `Node` 派生出 `ValueNode` 和 `Nodes`，分别提供有值节点和数组节点的额外成员和方法。所有其他类型的节点最终都继承自这三种节点。

继承关系：

```cpp
class ValueNode : public Node;
class Nodes : public Node;
```

[ast]: https://github.com/hakula139/pcat_parser/tree/master/src/ast

### 7.1 `Node`

`Node` 类的实现如下所示：

```cpp
// src/ast/node.hpp

class Node {
 public:
  explicit Node(const yy::location& loc) : loc_{loc} {}
  virtual ~Node() {}

  virtual void UpdateDepth(int depth);
  virtual void Print(std::ostream& os) const;

  virtual std::string name() const { return name_; }
  yy::location loc() const { return loc_; }
  void set_loc(const yy::location& loc) { loc_ = loc; }
  void set_depth(int depth) { depth_ = depth; }

 protected:
  void PrintIndent(std::ostream& os) const;
  void PrintLocation(std::ostream& os) const;
  void PrintBase(std::ostream& os) const;

 private:
  const std::string name_ = "node";
  yy::location loc_;
  int depth_ = 0;
};
```

```cpp
// src/ast/node.cpp

void Node::UpdateDepth(int depth) { set_depth(depth); }

void Node::Print(std::ostream& os) const {
  PrintBase(os);
  os << "\n";
}

void Node::PrintIndent(std::ostream& os) const {
  os << std::string(depth_ * 2, ' ');
}

void Node::PrintLocation(std::ostream& os) const {
  os << "<" << loc_.begin.line << ":" << loc_.begin.column << "-"
     << loc_.end.line << ":" << loc_.end.column << ">";
}

void Node::PrintBase(std::ostream& os) const {
  PrintIndent(os);
  os << name() << " ";
  PrintLocation(os);
}
```

主要提供了 `Node` 的构造函数和两个方法 `UpdateDepth()` 和 `Print()`。

其中，构造函数传入参数 `loc`，代表 token 目前所在的位置，保存在对象中。

函数 `UpdateDepth()` 的作用是为了维护 AST 的树形结构。对于每个节点 `x`，其 `UpdateDepth()` 的逻辑是：传入当前节点的深度 `depth`，更新自己的深度 `depth_`，然后「递归」调用所有子节点（如果有）的 `UpdateDepth()`，传入参数 `depth + 1`。具体可以参考下面这个例子（`Body`）：

```cpp
// src/ast/body.cpp

void Body::UpdateDepth(int depth) {
  Node::UpdateDepth(depth);
  if (p_decls_) p_decls_->UpdateDepth(depth + 1);
  if (p_stmts_) p_stmts_->UpdateDepth(depth + 1);
}
```

其中 `p_decls_` 和 `p_stmts_` 就是该节点的子节点的指针。

在最后打印 AST 前，我们调用一次根节点 `program` 的 `UpdateDepth()`，就可以更新整个 AST 所有节点的深度了。根节点的深度为 0，每个子节点的深度都是其父节点的深度加 1。

为什么需要这个深度信息呢？主要是为了方便在打印时缩进，从而体现 AST 的树形结构。我们可以看到在 `PrintIndent()` 函数里，每个节点的缩进宽度是 `depth_ * 2` 个空格，于是我们就可以通过缩进宽度来表示每个节点的深度了。

打印节点时，打印的内容是该节点的名称 `name_` 和位置 `loc_`。

### 7.2 `ValueNode`

`ValueNode` 类的实现如下所示：

```cpp
// src/ast/node.hpp

class ValueNode : public Node {
 public:
  explicit ValueNode(const yy::location& loc, const std::string& value = "")
      : Node{loc}, value_{value} {}

  void Print(std::ostream& os) const override;

  std::string name() const override { return name_; }
  virtual std::string value() const { return value_; }

 private:
  const std::string name_ = "node";
  const std::string value_;
};
```

```cpp
// src/ast/node.cpp

void ValueNode::Print(std::ostream& os) const {
  PrintBase(os);
  os << " " << value() << "\n";
}
```

`ValueNode` 比 `Node` 主要就是多保存了一个节点的语义值 `value_`，并围绕 `value_` 新增 / 修改了相关方法，比如构造时多传入一个参数 `value`，打印时多打印一个节点的语义值 `value()`。注意这里的 `value()` 和前面 `Node` 里的 `name()` 都是虚函数，因此可以被派生类的实现覆盖。

### 7.3 `Nodes`

`Nodes` 类的实现如下所示：

```cpp
// src/ast/node.hpp

class Nodes : public Node {
 public:
  explicit Nodes(const yy::location& loc) : Node{loc} {}

  void Insert(SPtr<Node> p_node);
  void InsertArray(SPtr<Nodes> p_nodes);
  void UpdateDepth(int depth) override;
  void Print(std::ostream& os) const override;

  std::string name() const override { return name_; }

 private:
  const std::string name_ = "nodes";
  std::vector<SPtr<Node>> data_;
};
```

```cpp
// src/ast/node.cpp

void Nodes::Insert(SPtr<Node> p_node) {
  if (p_node) {
    set_loc(loc() + p_node->loc());
    data_.push_back(p_node);
  }
}

void Nodes::InsertArray(SPtr<Nodes> p_nodes) {
  if (p_nodes) {
    for (auto&& p_node : p_nodes->data_) {
      Insert(p_node);
    }
  }
}

void Nodes::UpdateDepth(int depth) {
  Node::UpdateDepth(depth);
  for (auto&& p_node : data_) {
    if (p_node) p_node->UpdateDepth(depth + 1);
  }
}

void Nodes::Print(std::ostream& os) const {
  if (data_.size()) {
    Node::Print(os);
    for (const auto& p_node : data_) {
      if (p_node) p_node->Print(os);
    }
  }
}
```

`Nodes` 比 `Node` 主要是多了一个数组成员 `data_`，包含了所有子节点的指针，并围绕 `data_` 新增 / 修改了相关方法，比如提供了插入节点的方法 `Insert()` 和插入另一个数组节点的所有子节点的方法 `InsertArray()`。注意这里插入节点时会调用 `set_loc()` 自动更新本节点的位置 `loc_`，因此不需要在 Parser 里显式更新了。

这里有一点可以改进的地方是，数组成员 `data_` 的元素类型不应该是 `std::shared_ptr<Node>`，而应该是泛型 `std::shared_ptr<T>` 或者 `T`，然后派生类在继承时特化。我这里是懒了，毕竟不影响结果，只是缺少了一个运行时的类型检查，以及缺失了一定的语义（例如 `Lvalues` 类的 `data_` 的元素类型应当只能是 `std::shared_ptr<Lvalue>` 而不能是别的）。

### 7.4 如何继承

其他节点就是继承自这三个基类了，逻辑上基本没有大的变化，只是针对自己的情形做了一些调整。例如：

#### 7.4.1 `Node` 类的派生类: `Body`

```cpp
// src/ast/body.hpp

class Body : public Node {
 public:
  explicit Body(
      const yy::location& loc, SPtr<Decls> p_decls, SPtr<Stmts> p_stmts)
      : Node{loc}, p_decls_{p_decls}, p_stmts_{p_stmts} {}

  void UpdateDepth(int depth) override;
  void Print(std::ostream& os) const override;

  std::string name() const override { return name_; }

 private:
  const std::string name_ = "body";
  SPtr<Decls> p_decls_;
  SPtr<Stmts> p_stmts_;
};
```

```cpp
// src/ast/body.cpp

void Body::UpdateDepth(int depth) {
  Node::UpdateDepth(depth);
  if (p_decls_) p_decls_->UpdateDepth(depth + 1);
  if (p_stmts_) p_stmts_->UpdateDepth(depth + 1);
}

void Body::Print(std::ostream& os) const {
  Node::Print(os);
  if (p_decls_) p_decls_->Print(os);
  if (p_stmts_) p_stmts_->Print(os);
}
```

对函数 `UpdateDepth()`, `Print()`, `name()` 进行了覆盖（override），同时修改节点名 `name_` 为 `body`。这里为什么需要覆盖 `name()` 函数，是因为基类的 `name()` 只能访问到基类的 `name_`，而不能访问派生类的 `name_`（没有虚成员变量的概念），所以即使 `name()` 的定义是一样的，仍然需要重新定义一遍。

{{< admonition quote "笔者注（2022-10-05）" >}}
现在看来，这里的实现是有问题的。不应该在派生类重新定义一个 `name_` 隐藏基类的 `name_`，而应该在派生类的构造函数里给基类的 `name_` 赋一个新的值。这样就不需要在派生类里重新定义 `name()` 了，同时 `name()` 也不再需要声明为虚函数。
{{< /admonition >}}

构造时，传入的参数就是该节点的子节点的指针，保存在对象中。之后在调用函数 `UpdateDepth()` 和 `Print()` 时，就可以直接向下「递归」了。对于叶节点，函数 `UpdateDepth()` 和 `Print()` 不进行覆盖，而是直接使用基类的实现。

#### 7.4.2 `ValueNode` 类的派生类: `BinaryExpr`

```cpp
// src/ast/expr.hpp

class Expr : public ValueNode {
 public:
  explicit Expr(const yy::location& loc, const std::string& value = "")
      : ValueNode{loc, value} {}

  std::string name() const override { return name_; }

 private:
  const std::string name_ = "expression";
};

class BinaryExpr : public Expr {
 public:
  explicit BinaryExpr(
      const yy::location& loc,
      SPtr<Expr> p_expr1,
      SPtr<Op> p_op,
      SPtr<Expr> p_expr2)
      : Expr{loc}, p_expr1_{p_expr1}, p_op_{p_op}, p_expr2_{p_expr2} {}

  void UpdateDepth(int depth) override;
  void Print(std::ostream& os) const override;

  std::string name() const override { return name_; }
  std::string value() const override;

 private:
  const std::string name_ = "binary expression";
  SPtr<Expr> p_expr1_;
  SPtr<Op> p_op_;
  SPtr<Expr> p_expr2_;
};
```

```cpp
// src/ast/expr.cpp

void BinaryExpr::UpdateDepth(int depth) {
  Expr::UpdateDepth(depth);
  if (p_expr1_) p_expr1_->UpdateDepth(depth + 1);
  if (p_op_) p_op_->UpdateDepth(depth + 1);
  if (p_expr2_) p_expr2_->UpdateDepth(depth + 1);
}

void BinaryExpr::Print(std::ostream& os) const {
  Expr::Print(os);
  if (p_expr1_) p_expr1_->Print(os);
  if (p_op_) p_op_->Print(os);
  if (p_expr2_) p_expr2_->Print(os);
}

std::string BinaryExpr::value() const {
  auto expr1 = p_expr1_ ? p_expr1_->value() : "";
  auto op = p_op_ ? p_op_->value() : "";
  auto expr2 = p_expr2_ ? p_expr2_->value() : "";
  return expr1 + " " + op + " " + expr2;
}
```

相较于 `Node` 类的派生类，主要是多了一个对函数 `value()` 的覆盖。这个 `value()` 就是节点的语义值。通过这种方式，当 `expr1`, `op`, `expr2` 的语义值分别为 `(1 + 2)`, `*`, `3` 时，我们就可以得到本节点的语义值 `(1 + 2) * 3`。一方面形式上非常统一，另一方面不需要相同实现重复定义，这就是虚函数的妙处。

#### 7.4.3 `Nodes` 类的派生类: `Stmts`

```cpp
// src/ast/stmt.hpp

class Stmts : public Nodes {
 public:
  explicit Stmts(const yy::location& loc) : Nodes{loc} {}

  std::string name() const override { return name_; }

 private:
  const std::string name_ = "statement list";
};
```

只需要改个名字就可以了。

#### 7.4.4 一些特例: `WriteExpr`

```cpp
// src/ast/expr.hpp

class WriteExpr : public Expr {
 public:
  using UnionPtr = std::variant<SPtr<String>, SPtr<Expr>>;

  explicit WriteExpr(const yy::location& loc, UnionPtr p_write_expr)
      : Expr{loc}, p_write_expr_{p_write_expr} {}

  void UpdateDepth(int depth) override;
  void Print(std::ostream& os) const override;

  std::string name() const override { return name_; }
  std::string value() const override;

 private:
  const std::string name_ = "write expression";
  UnionPtr p_write_expr_;
};
```

```cpp
// src/base/common.hpp

// Code snippets for visiting std::variant.
// See: https://en.cppreference.com/w/cpp/utility/variant/visit
template <class... Ts>
struct Overloaded : Ts... {
  using Ts::operator()...;
};
template <class... Ts>
Overloaded(Ts...) -> Overloaded<Ts...>;
```

```cpp
// src/ast/expr.cpp

void WriteExpr::UpdateDepth(int depth) {
  Expr::UpdateDepth(depth);
  auto visitor = Overloaded{
      [depth](auto&& p) {
        if (p) p->UpdateDepth(depth + 1);
      },
  };
  std::visit(visitor, p_write_expr_);
}

void WriteExpr::Print(std::ostream& os) const {
  Expr::Print(os);
  auto visitor = Overloaded{
      [&os](auto&& p) {
        if (p) p->Print(os);
      },
  };
  std::visit(visitor, p_write_expr_);
}

std::string WriteExpr::value() const {
  auto visitor = Overloaded{
      [](const auto& p) {
        auto value = p ? p->value() : "";
        return value;
      },
  };
  return std::visit(visitor, p_write_expr_);
}
```

因为用了 C++17 的高级语法，看起来非常抽象。实际上这个 `WriteExpr` 类干的是这样一个事情：传入一个类型可能是 `SPtr<String>` 也可能是 `SPtr<Expr>` 的参数，并保存在同一个变量 `p_write_expr_` 里。调用时，动态判断实际保存的是哪一个类型，并进行相应的操作。

没错，`p_write_expr_` 的本质约等于是一个 C 语言的 union。但 union 大概只能用于 POD 类型（或许存在一些奇技淫巧），因此这里我们使用了 C++17 的 `std::variant` 类型，提供了对非 POD 类型的支持。至于 `std::visit`，就是访问这个 `std::variant` 的手段了，具体建议参考 [cppreference][visit-cppref]，这里不作赘述。

为什么要这样设计？没办法嘛，产生式就是这样写的。正常来说，应该要让 `String` 和 `Expr` 都继承 `WriteExpr`，这样就可以将 `String` 和 `Expr` 的指针赋值给 `WriteExpr` 的指针了。但显然不是那么回事，`WriteExpr` 在语义上当然不能是 `String` 或者 `Expr` 的基类，所以只能这样写了。

[visit-cppref]: https://en.cppreference.com/w/cpp/utility/variant/visit

### 7.5 继承关系

最后，我在这里统一列一下所有类之间的继承关系（除基类外按首字母顺序）。

#### 7.5.1 三个基类

```cpp
class ValueNode : public Node;
class Nodes : public Node;
```

参见 [`src/ast/node.hpp`][node.hpp]。

[node.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/node.hpp

#### 7.5.2 Body

```cpp
class Body : public Node;
```

参见 [`src/ast/body.hpp`][body.hpp]。

[body.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/body.hpp

#### 7.5.3 所有常量类

```cpp
template <class T> class Constant : public Node;
class Integer : public Constant<std::string>;
class Real : public Constant<std::string>;
class Number : public ValueNode;
class String : public Constant<std::string>;
```

参见 [`src/ast/constant.hpp`][constant.hpp]。

这里本来 `Integer` 和 `Real` 分别继承自 `Constant<int32_t>` 和 `Constant<double>`，这也是为什么 `Constant` 被声明成一个模板类。在 [4.2](#42-bison-declaration) 节我们解释过为什么后来改成了 `Constant<std::string>`。

[constant.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/constant.hpp

#### 7.5.4 所有声明类

```cpp
class Decl : public Node;
class Decls : public Nodes;
class VarDecl : public Decl;
class VarDecls : public Decls;
class TypeDecl : public Decl;
class TypeDecls : public Decls;
class ProcDecl : public Decl;
class ProcDecls : public Decls;
```

参见 [`src/ast/decl.hpp`][decl.hpp]。

[decl.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/decl.hpp

#### 7.5.5 所有表达式类

```cpp
class Expr : public ValueNode;
class Exprs : public Nodes;
class NumberExpr : public Expr;
class LvalueExpr : public Expr;
class ParenExpr : public Expr;
class UnaryExpr : public Expr;
class BinaryExpr : public Expr;
class ProcCallExpr : public Expr;
class AssignExpr : public Expr;
class AssignExprs : public Exprs;
class CompValues : public Node;
class RecordConstrExpr : public Expr;
class ArrayExpr : public Expr;
class ArrayExprs : public Exprs;
class ArrayValues : public Node;
class ArrayConstrExpr : public Expr;
class WriteExpr : public Expr;
class WriteExprs : public Exprs;
```

参见 [`src/ast/expr.hpp`][expr.hpp]。

[expr.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/expr.hpp

#### 7.5.6 Identifier

```cpp
class Id : public ValueNode;
class Ids : public Nodes;
```

参见 [`src/ast/identifier.hpp`][identifier.hpp]。

[identifier.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/identifier.hpp

#### 7.5.7 所有左值类

```cpp
class Lvalue : public ValueNode;
class Lvalues : public Nodes;
class IdLvalue : public Lvalue;
class ArrayElemLvalue : public Lvalue;
class RecordCompLvalue : public Lvalue;
```

参见 [`src/ast/lvalue.hpp`][lvalue.hpp]。

[lvalue.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/lvalue.hpp

#### 7.5.8 Operator

```cpp
class Op : public ValueNode;
```

参见 [`src/ast/operator.hpp`][operator.hpp]。

[operator.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/operator.hpp

#### 7.5.9 所有参数类

```cpp
class Param : public Node;
class Params : public Nodes;
class FormalParam : public Param;
class FormalParams : public Params;
class ActualParams : public Exprs;
class ReadParams : public Lvalues;
class WriteParams : public WriteExprs;
```

参见 [`src/ast/param.hpp`][param.hpp]。

[param.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/param.hpp

#### 7.5.10 Program

```cpp
class Program : public Node;
```

参见 [`src/ast/program.hpp`][program.hpp]。

[program.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/program.hpp

#### 7.5.11 所有语句类

```cpp
class Stmt : public Node;
class Stmts : public Nodes;
class AssignStmt : public Stmt;
class ProcCallStmt : public Stmt;
class ReadStmt : public Stmt;
class WriteStmt : public Stmt;
class ElifSection : public Node;
class ElifSections : public Nodes;
class ElseSection : public Node;
class IfStmt : public Stmt;
class WhileStmt : public Stmt;
class LoopStmt : public Stmt;
class ForStep : public Node;
class ForStmt : public Stmt;
class ExitStmt : public Stmt;
class ReturnStmt : public Stmt;
```

参见 [`src/ast/stmt.hpp`][stmt.hpp]。

[stmt.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/stmt.hpp

#### 7.5.12 所有类型类

```cpp
class Type : public Node;
class TypeAnnot : public Node;
class Component : public Node;
class Components : public Nodes;
class IdType : public Type;
class ArrayType : public Type;
class RecordType : public Type;
```

参见 [`src/ast/type.hpp`][type.hpp]。

[type.hpp]: https://github.com/hakula139/pcat_parser/blob/master/src/ast/type.hpp

## 参考资料

1. [Bison 3.8.1][bison-man]
2. [The PCAT Programming Language Reference Manual][pcat]

[bison-man]: https://www.gnu.org/software/bison/manual/html_node
[pcat]: http://web.cecs.pdx.edu/~harry/compilers/PCATLangSpec.pdf
