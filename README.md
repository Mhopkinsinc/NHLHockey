# NHL Hockey (also known as NHL 92'): Project Setup

This project contains tools for compiling NHL Hockey for the Sega Genesis using ASM68K compiler.

## Initial Setup

1. Clone/extract this repository
2. Open in VSCode or editor of choice

## Project Structure

```
Root/
├── assembler/            # Assembler (Windows Only)
├── output/               # Build output
├── src/                  # Source assembly files and assets
│   ├── _docs/              # Documentation files
│   ├── graphics/           # Graphic assets
│   ├── macros/             # Assembly macros
│   ├── sega/               # Sega-specific code
│   ├── sound/              # Sound assets
│   └── *.asm               # Assembly files
├── build.bat             # Batch File for Invoking Assembler to Compile Source Code
```

## Building

1. Run the build.bat file from the command prompt or terminal.
2. Batch file should generate the following files in the `output` folder:
```
    output/
    ├── Build.log             # Log file containing any errors during compilation.
    ├── nhl92.bin             # ROM file if the build was successful without errors.
    ├── nhl92.lst             # Debug information generated during the build.
    └── nhl92.map             # Symbol file used for debugging.
```