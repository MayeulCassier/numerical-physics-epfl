# EPFL Numerical Physics Exercises

<p align="right"><img src="assets/mayeul-cassier-mark.svg" width="64" alt="Mayeul Cassier monogram" /></p>

This repository collects the working code submissions for the EPFL numerical physics exercise series completed across two bachelor semesters.

![Conceptual numerical-physics simulation](assets/numerical-physics-simulation.png)

It consolidates:

- `PhysNum Again` from Bachelor semester 3
- `PhysnumII` from Bachelor semester 4

Only the submitted working code, analysis scripts, configuration files, exercise statements, and final reports are kept. Generated plots, raw output files, zip archives, Overleaf folders, and vendored third-party libraries were intentionally excluded.

## Contents

```text
.
|-- exercises/
|   |-- exercise-01/
|   |-- exercise-02/
|   |-- exercise-03/
|   |-- exercise-04/
|   |-- exercise-05/
|   |-- exercise-06/
|   |-- exercise-07/
|   `-- exercise-08/
`-- docs/
    `-- statements/        # Original exercise statements
```

Each exercise follows the same structure:

```text
exercise-XX/
|-- code/                  # C++ sources and headers
|-- configs/               # Input configuration files
|-- analysis/              # MATLAB post-processing and parameter scans
`-- report/report.pdf      # Submitted report
```

## Build and Run

Most exercises are standalone C++ programs accompanied by MATLAB scripts for parameter scans and analysis.
Exercise 05 includes Boost headers (`boost/random.hpp`), so a local Boost installation may be required for that one.

Example:

```bash
cd exercises/exercise-03
g++ -std=c++17 code/Exercice3_Frankhauser_Cassier.cpp -o exercise-03
./exercise-03 configs/configuration.in
```

Some programs may expect the configuration file in the current directory rather than as a command-line argument. In that case, copy or symlink the relevant `.in` file next to the executable before running.

MATLAB scripts in `analysis/` are preserved as submitted analysis workflows. They usually assume that the corresponding C++ executable has already generated result files.

## Exercise Index

| Exercise | Main code | Analysis scripts | Config files | Report |
|---|---:|---:|---:|---|
| 01 | yes | yes | yes | yes |
| 02 | yes | yes | yes | yes |
| 03 | yes | yes | yes | yes |
| 04 | yes | yes | yes | yes |
| 05 | yes | no | yes | yes |
| 06 | yes | yes | yes | yes |
| 07 | yes | yes | yes | yes |
| 08 | yes | yes | yes | yes |

## Notes

- The repository is a curated public archive, not a full rebuild of the original course folders.
- The final reports are included because they explain the numerical methods, experiments, and interpretation.
- The original source folders contained many generated figures and archives; those are intentionally excluded to keep the repository readable.
