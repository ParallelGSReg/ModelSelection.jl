# ModelSelection

[![][documentation-main-img]][documentation-main-url] [![][build-main-img]][build-main-url]

*Model Selection for Julia.*

## Features

We would like to inform you that the features documentation for the latest version of our package is currently pending. As we are preparing to release a new version, our development team is working diligently to finalize the features and functionalities included in this update.

## Installation

You can install the package by running the following command in the Julia REPL:

```julia
using Pkg
Pkg.add("ModelSelection")
```

## Usage

To start perform model selection and save and load the results, follow these steps:
To start to perform model selection and manage results, follow these steps:

```julia
model = ModelSelection.gsr(:ols, ...)
ModelSelection.save("result.jld", model)  # Saves model
ModelSelection.save_csv("result.csv", model)  # Saves the results to csv
model = ModelSelection.load("result.jld")  # Loads the model
```

## Documentation

For more detailed information about this package, its functionalities, and usage instructions, please refer to our [documentation page](https://parallelgsreg.github.io/ModelSelection.jl).

## ModelSelectionGUI package

ModelSelection.jl has a web server package designed to provide a user-friendly interface for utilizing the ModelSelection package. It consists of a backend and an optional frontend that offers a graphical user interface (GUI) for seamless interaction with the underlying ModelSelection functionality. package functions as an interface with ModelSelection.jl. For more details about the functionalities and features provided by ModelSelectionGUI.jl, please visit the [package repository](https://github.com/ParallelGSReg/ModelSelectionGUI.jl).

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request on the repository. Make sure to follow the guidelines outlined in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## TODO List

For an overview of pending tasks, improvements, and future plans for the ModelSelectionGUI package, please refer to the [TODO.md](TODO.md) file.

## License

This package is licensed under the [MIT License](LICENSE).

## Credits

The ModelSelection module, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Adán Mauri Ungaro](https://github.com/adanmauri/), [Nicolás Monzón](https://github.com/nicomzn) and [Valentín Mari](https://github.com/vmari/). The ModelSelection.jl module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).

[build-main-img]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/build.yaml/badge.svg?branch=main
[build-main-url]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/build.yaml

[test-main-img]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/test.yaml/badge.svg?branch=main
[test-main-url]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/test.yaml

[codecov-img]: https://codecov.io/gh/ParallelGSReg/ModelSelection.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/ParallelGSReg/ModelSelection.jl

[documentation-main-img]: https://github.com/ParallelGSReg/ModelSelection.jl/actions/workflows/docs.yaml/badge.svg
[documentation-main-url]: https://parallelgsreg.github.io/ModelSelection.jl
