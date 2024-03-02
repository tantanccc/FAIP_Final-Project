# -*- coding: utf-8 -*-

# ¡ifull code for running on cluster¡j
#--------------------feed initial data into botorch--------------------------
import os

# Define the input file path
input_file_path = "/home/htli/pipeline/botorch/initial_dataset/10_seeds.txt"

# Extract the directory path and file name from the input file path
directory, input_file_name = os.path.split(input_file_path)

# Create the output file path by adding 'filtered_' as a prefix to the input file name
output_file_name = "filtered_" + input_file_name
output_file_path = os.path.join(directory, output_file_name)

# Open the input file for reading and create the output file for writing
with open(input_file_path, 'r') as input_file, open(output_file_path, 'w') as output_file:
    # Iterate through the lines in the input file
    for line in input_file:
        # Check if the line contains a valid second value
        if ',' in line and line.split(',')[1]:
            # If the line has a valid second value, write it to the output file
            output_file.write(line)
            
#-----------clean the data and store them as h and VM stress------------------
import numpy as np

# Read the text file
with open(output_file_path, "r") as file:
    lines = file.readlines()

# Initialize lists to store h and VM stress values
h_values = []
VM_stress_values = []

# Iterate through the lines and extract the data
for line in lines:
    parts = line.strip().split(",")
    if len(parts) == 3:
        resolution, VM_str, h_str = parts
        h = float(h_str.split("_")[1][1:])  # Extract the h value

        #VM_stress = VM_str
        VM_stress = float(VM_str)
        h_values.append(h)
        VM_stress_values.append(VM_stress)

# Convert the lists to NumPy arrays
h = np.array(h_values)
VM = np.array(VM_stress_values)

print("h =", h)
print("VM =", VM)
