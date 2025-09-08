# PyRMap

**PyRMap** is a tool designed to enable fast and clean communication between **R** and **Python** by leveraging the `mmap` system call.  
Instead of relying on higher-overhead bridges like `reticulate` or `rpy2`, PyRMap shares data directly through memory-mapped files, backed by disk for persistence but effectively zero-copy between processes.
---

## Concept

PyRMap uses three shared binary files stored in `/tmp`:

1. **`METADATA_FILE`**  
   Contains metadata describing the data exchange. Layout:
   - **flag**:  
     - `0` → data prepared by R, ready for Python  
     - `1` → result prepared by Python, ready for R  
   - **input length** (number of elements)  
   - **data type code** (encoding of element type)  
   - **result length** (number of elements in the result)

   > Note: *length* = number of elements, while *size* = length × element size in bytes.

2. **`DATA_FILE`**  
   Contains the raw input data written by R.

3. **`RESULT_FILE`**  
   Contains the result data written by Python.

Supported data types:
- `int32`
- `int64`
- `float32`
- `float64`
- `uint8`

---

## Data Flow

1. R writes input data into `DATA_FILE` and metadata into `METADATA_FILE`.  
   Both files are created as memory-mapped binary files, so the data is already in RAM, backed by disk.

2. A Python script is executed as a separate process. It:
   - Reads `METADATA_FILE` (already mapped in memory, no extra copy).  
   - Reads `DATA_FILE` (also mapped in memory).  
   - Computes the result and writes it into `RESULT_FILE`.  
   - Updates `METADATA_FILE` with the result size and sets the flag to `1`.

3. R reads the result from `RESULT_FILE` (already mapped in memory, no overhead) and returns it to the caller.

This design ensures **zero-copy data exchange** between R and Python, while maintaining persistence via the backing `.bin` files.

---

## Usage

### In R

Import the helper functions from `lib/run_python.R`.

- **Single script execution**  
  Use `run_python(data, python_script_path, dtype)` to run a single Python script.  
  Example: [`example/test_sum.R`](example/test_sum.R)

- **Multiple scripts with shared input**  
  Use `run_python_shared_data(data, script_paths, dtype)` to run multiple Python scripts sequentially on the same input data.  
  Returns a list of results in the same order as the script paths.
  Example: [`example/test_multiple_calls_one_data_file.R`](example/test_multiple_calls_one_data_file.R)

- **Pipeline execution**  
  Use `run_python_pipeline(data, script_paths, dtype)` to run a sequence of Python scripts, where the result of each script is passed as input to the next.  
  Example: [`example/test_pipeline.R`](example/test_pipeline.R)

### In Python

Import the decorator `process_via_mmap` from `lib/process_with_mmap.py` and wrap your function with it.  
Each Python script in the [`example`](example) folder demonstrates this usage.

---

## Notes and Limitations

- PyRMap currently works only on **Linux**, since it relies on the `mmap` system call.  
- At this stage, you cannot call a specific function inside a Python script — the entire file is executed.  
- Intermediate results are not available when using `run_python_pipeline` (planned feature).  
- `run_python_shared_data` executes scripts **sequentially**, not in parallel (parallel execution may be added in the future).  

---

## Why PyRMap?

- Zero-copy data transfer between R and Python  
- Memory-mapped files for high performance  
- Cleaner separation of processes compared to `reticulate` or `rpy2`  
- Explicit handling of metadata for robust cross-language communication
