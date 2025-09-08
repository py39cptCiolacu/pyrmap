# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Support for parallel execution in `run_python_shared_data`.
- Add option to inspect intermediate results in pipeline mode.

## [0.1.0] - 2025-09-08
### Added
- Initial release of PyRMap.
- `run_python`, `run_python_shared_data`, and `run_python_pipeline` functions.
- Basic R ↔ Python communication using `mmap`.
- Support for `int32`, `int64`, `float32`, `float64`, `uint8`.
