# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Support for parallel execution in `run_python_shared_data`.
- Add option to inspect intermediate results in pipeline mode.

## [0.3.0] - 2025-10-17
- introduced a new parater in run_pipelune function - required_intermediate_results, default FALSE
- setting required_intermediate_results to TRUE, will result in run_pipeline to return a list of results, for every script called in the pipeline

## [0.2.0] - 2025-09-17
- introduced a new parameter - "path". Set to RAM, the DATA_FILE and RESULT_FILE will be stored in /dev/shm. Set to DISK will be stored in /home/pyrmap/storage

## [0.1.0] - 2025-09-08
- Initial release of PyRMap.
- `run_python`, `run_python_shared_data`, and `run_python_pipeline` functions.
- Basic R ↔ Python communication using `mmap`.
- Support for `int32`, `int64`, `float32`, `float64`, `uint8`.
