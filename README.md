# Geomorphometry2025 Workshop

Workshop: Propagating DEM Uncertainty to Stream Extraction using GRASS at Geomorphometry 2025

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ncsu-geoforall-lab/geomorphometry2025_workshop/blob/main/geomorphometry_2025_workshop.ipynb)[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15283713.svg)](https://doi.org/10.5281/zenodo.15283713)

## Local Setup

The project uses [Jupyter Notebook](https://jupyter.org/) and can be run locally. To do this, you need to have Python installed on your machine. The project is managed with [uv](https://docs.astral.sh/uv/) to install **uv** you can use the following command:

### macOS or Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### wget

```bash
wget -qO- https://astral.sh/uv/install.sh | sh
```

### Windows

```bash
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

You can also install **uv** though various package manganger by following the instruction found [here](https://docs.astral.sh/uv/getting-started/installation/). Once you have **uv** installed, you can run the following command to create a virtual environment and install the required packages:

```bash
uv sync
```

This will create a virtual environment in the `.venv` directory and install all the required packages listed in the `uv.lock` file. Once the installation is complete, you can activate the virtual environment using the following command:

## Activate the Virtual Environment

```bash
source .venv/bin/activate
```

Make sure your Jupyter Notebooks kernal is set to the virtual environment.
