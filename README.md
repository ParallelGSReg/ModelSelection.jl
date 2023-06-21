# ModelSelection

[![][documentation-main-img]][documentation-main-url] [![][build-main-img]][test-main-url] [![][test-main-img]][test-main-url] [![][codecov-img]][codecov-url]

*Model Selection for Julia.*

## Documentation
Please follow [the next link](https://parallelgsreg.github.io/ModelSelection.jl/).

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

## ModelSelectionGUI package
ModelSelection.jl has a web server package designed to provide a user-friendly interface for utilizing the ModelSelection package. It consists of a backend and an optional frontend that offers a graphical user interface (GUI) for seamless interaction with the underlying ModelSelection functionality. package functions as an interface with ModelSelection.jl. For more details about the functionalities and features provided by ModelSelectionGUI.jl, please visit the [package repository](https://github.com/ParallelGSReg/ModelSelectionGUI.jl).

## Credits
The ModelSelection module, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Adán Mauri Ungaro](https://github.com/adanmauri/), [Nicolás Monzón](https://github.com/nicomzn) and [Valentín Mari](https://github.com/vmari/). The ModelSelection.jl module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request on the repository. Make sure to follow the guidelines outlined in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## TODO List

For an overview of pending tasks, improvements, and future plans for the ModelSelectionGUI package, please refer to the [TODO.md](TODO.md) file.

## License

This package is licensed under the [MIT License](LICENSE).

[![Build test](https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/build.yaml/badge.svg)](https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/build.yaml)

[build-main-img]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/build.yaml/badge.svg?branch=main
[build-main-url]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/build.yaml

[test-main-img]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/test.yaml/badge.svg?branch=main
[test-main-url]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/test.yaml

[codecov-img]: https://codecov.io/gh/ParallelGSReg/ModelSelection.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/ParallelGSReg/ModelSelection.jl

[documentation-main-img]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/docs.yaml/badge.svg
[documentation-main-url]: https://parallelgsreg.github.io/ModelSelection.jl
