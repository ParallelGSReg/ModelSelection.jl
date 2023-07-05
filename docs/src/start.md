# Getting started

This basic example demonstrates how to use the package in its simplest way. However, for a more in-depth understanding of the various options and features, please navigate to the [Usage section](usage.md) where all available functionalities and usage scenarios are thoroughly explained.

## Installation

ModelSelection can be installed using the Julia package manager. From the Julia REPL, type ] to enter the Pkg REPL mode and run

```
pkg> add ModelSelection
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
