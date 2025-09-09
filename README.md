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

## Under the Hood: How Memory Mapping Works

PyRMap relies on the Linux `mmap` system call to allow R and Python processes to communicate via shared memory.

### Key Concepts
- **Memory mapping** (`mmap`) creates a mapping between a file on disk and a region of virtual memory.
- When R writes to `DATA_FILE` and `METADATA_FILE`, the operating system loads their content into memory pages managed by the Linux kernel.
- When Python opens and memory-maps the same files, the kernel does not reload them from disk.  
  Instead, it provides access to the **same memory pages** that are already in RAM.

### Why This Matters
- **Zero-copy communication**: both R and Python read/write directly in the same memory pages.
- **Synchronization by design**: any change written by one process becomes visible to the other without extra copying.
- **Backed by files**: although the files are on disk (e.g., `/tmp/metadata.bin`), the actual operations happen in RAM. The files exist primarily so both processes can refer to the same memory region.

### Important Notes
- Python and R are not "aware" of each other's mappings. They simply open and map the same file path.
- The Linux kernel ensures that the mappings overlap in memory, enabling shared access.
- Using `/dev/shm` (a tmpfs-backed directory) can further reduce overhead, since it is already backed by RAM. `/tmp` also works but may be slower if not mounted as `tmpfs`.

## Usage

### Setup

**Prerequisites** 
- Python3 
- R
- Linux OS (the "mmap" package relies on Linux syscalls)

**Steps**
- Create a python virtual env and install the requiresd libraries from 'req.txt':
- install "mmap" package for R
- activate .venv
- set PYTHONPATH="path/to/pyrmap"


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



---

## License

This project is licensed under the [Apache License 2.0]
