import numpy as np
from lib.s3_data_reader import read_and_create_s3_object

def print_s3_object():
    s3_object = read_and_create_s3_object()
    print(s3_object.__dict__)    

if __name__ == "__main__":
    print_s3_object()
