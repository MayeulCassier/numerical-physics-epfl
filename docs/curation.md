# Curation Notes

The source material came from two local EPFL course folders:

- Bachelor semester 3, `PhysNum Again`
- Bachelor semester 4, `PhysnumII`

Selection rules:

- Kept submitted/rendu folders for exercises 1 to 8.
- Kept C++ sources, headers, MATLAB scripts, input configurations, exercise statements, and final reports.
- Added missing `ConfigFile` headers/templates and default configuration files from the original exercise folders when a submitted source file required them to run.
- Excluded generated figures, `.fig` files, `.eps` files, `.jpg` files, gifs, output data, zip archives, Overleaf project folders, and vendored dependencies such as Boost.
- Standardized final report names to `report/report.pdf`.

Validation performed during curation:

- Checked that every exercise from 1 to 8 has at least one code file and one final report.
- Checked for unexpectedly large files; the largest tracked files are final PDF reports.
- Checked for common hardcoded token patterns; none were found.
