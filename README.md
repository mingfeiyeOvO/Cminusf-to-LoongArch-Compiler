# Cminusf-to-LoongArch Compiler

A complete compiler implementation that translates Cminusf (a C-like language) source code to LoongArch 64-bit assembly code.

## Overview

This compiler consists of four main components:

1. **Frontend**: Parses Cminusf source code and generates Abstract Syntax Tree (AST)
2. **IR Generation**: Converts AST to LightIR (LLVM-like intermediate representation) using visitor pattern
3. **Optimization**: Applies various optimization passes including SSA construction, dead code elimination, and loop optimizations
4. **Backend**: Generates LoongArch assembly code from optimized IR

## Features

### Language Support
- Basic data types: `int`, `float`, `void`
- Arrays and pointers
- Functions with parameters and return values
- Control flow: `if-else`, `while` loops
- Arithmetic and logical operations
- Built-in I/O functions

### Optimization Passes
- **Mem2Reg**: Promotes memory allocations to SSA registers
- **LICM**: Loop Invariant Code Motion
- **Dead Code Elimination**: Removes unused code and unreachable blocks

### Code Generation
- LoongArch 64-bit instruction set support
- Standard calling conventions
- Stack frame management
- Register allocation (stack-based)
- Floating-point operations


## Project Structure

```
├── src/
│   ├── cminusfc/          # Frontend and IR generation
│   ├── codegen/           # Backend code generation
│   ├── passes/            # Optimization passes
│   ├── lightir/           # IR framework
│   └── parser/            # Lexer and parser
├── include/               # Header files
└── tests/                 # Test cases
```


## Testing

The project includes comprehensive test suites covering:
- Basic language features
- Optimization correctness
- Code generation accuracy
- Performance benchmarks
