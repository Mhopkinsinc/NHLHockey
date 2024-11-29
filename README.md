# NHL Hockey (also known as NHL 92'): Project Setup

This project contains tools for compiling NHL Hockey for the Sega Genesis using ASM68K compiler.

## Initial Setup

1. Clone/extract this repository
2. Open in VSCode or editor of choice (Not required if just building the ROM)

## Project Structure

```
Root/
├── assembler/            # Assembler (Windows Only)
├── notebooks/            # Jyputer Notebooks for Additional Tooling (Not Required)
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

## Building (Windows)

1. Run the build.bat file from the command prompt or terminal.
2. Batch file should generate the following files in the `output` folder:
```
    output/
    ├── Build.log             # Log file containing any errors during compilation.
    ├── nhl92.bin             # ROM file if the build was successful without errors.
    ├── nhl92.lst             # Debug information generated during the build.
    └── nhl92.map             # Symbol file used for debugging.
```

## Building (Mac or Linux)

1. Requires Docker to be installed.
2. Clone the repo.
3. CD into NHLHockey folder.
4. Run the following comand to build the source files.
```
mkdir -p output && \
docker run --rm \
    -v "$(pwd)/src:/src" \
    -v "$(pwd)/output:/output" \
    rhargreaves/asm68k \
    /p /m /g /o d- /o s- /o r+ /o l+ /o l. /o ow+ /o op- /o os+ /o oz+ /o omq- /o oaq+ /o osq+ \
    "hockey.asm,/output/nhl92.bin,/output/nhl92,/output/nhl92" > output/build.log 2>&1
```
5. Results.
```
    output/
    ├── Build.log             # Log file containing any errors during compilation.
    ├── nhl92.bin             # ROM file if the build was successful without errors.
    ├── nhl92.lst             # Debug information generated during the build.
    └── nhl92.map             # Symbol file used for debugging.
```

## Developer Info

1. TBD: The wiki will be updated with additional findings, including detailed instructions on using the notebooks.