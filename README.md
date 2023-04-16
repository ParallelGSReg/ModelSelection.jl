# ModelSelection

[![Build test](https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/build.yaml/badge.svg)](https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/build.yaml)

*Model Selection for Julia.*

## How to save csv and results
```julia
model = ModelSelection.gsr(:ols, ...)
ModelSelection.save("result.jld", model)  # Saves model
ModelSelection.save_csv("result.csv", model)  # Saves csv
```

## How to load results
```julia
model = ModelSelection.load("result.jld")
```

## Credits
The ModelSelection module, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Adán Mauri Ungaro](https://github.com/adanmauri/), [Nicolás Monzón](https://github.com/nicomzn) and [Valentín Mari](https://github.com/vmari/). The ModelSelection.jl module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).

