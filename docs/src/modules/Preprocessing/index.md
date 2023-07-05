!!! warning
    TODO: this documentation is incomplete and currently under development. To see more detail of the module functions, go to the module sections.

# Preprocessing

This module process the data based on the various inputs that the package has.

## Contents

```@contents
Pages = ["index.md"]
```

## Index

```@index
Pages = ["index.md"]
```

## Usage

```julia
using CSV, DataFrames
using ModelSelection: Preprocessing

data = CSV.read("data.csv", DataFrame)

modelselection_data = input(equation, data)
```
