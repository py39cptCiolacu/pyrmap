from lib.process_with_mmap import process_via_mmap

@process_via_mmap
def num_plus_one(input_data):
    return input_data[0]+1

if __name__ == "__main__":
    num_plus_one()
