# Import necessary libraries
import numpy as np
import porespy as ps
from PIL import Image
import sys

# Check if both heterogeneity, SEEDS_AMOUNT and POROSITY are provided as command-line arguments
if len(sys.argv) < 5:
    print("Usage: python code_morphometry_v5.py <heterogeneity> <current_seed> <POROSITY> <SEEDS_AMOUNT>")
    sys.exit(1)

# Extract heterogeneity and SEEDS_AMOUNT from command-line arguments
heterogeneity = float(sys.argv[1])
current_seed = int(sys.argv[2])
POROSITY = float(sys.argv[3])
SEEDS_AMOUNT = int(sys.argv[4])

# Set other parameters
n = 1000  # Image size, 1000*1000
p = POROSITY

# Loop over the specified SEEDS_AMOUNT
for seed in range(current_seed, current_seed+SEEDS_AMOUNT):
    # Set the seed using the loop index
    np.random.seed(seed)

    # Generate the image using porespy
    im = ps.generators.blobs(shape=[n, n], porosity=p, blobiness=(n / 40 / heterogeneity) * np.array([1.0, 1.0]))

    # Construct the absolute file path for saving the image
    save_path = "/home/htli/pipeline/porespy/images/n{}_h{:.2f}_p{:.2f}_s{}.png".format(n, heterogeneity, p, seed)

    # Convert the image to PIL.Image (necessary for MOOSE) and save
    im_bin = np.array(1 - im * 1)
    im = Image.fromarray(np.uint8(im_bin) * 255, mode='L')
    im.save(save_path)
