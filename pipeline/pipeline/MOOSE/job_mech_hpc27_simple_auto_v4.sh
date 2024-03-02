#!/bin/bash
#PBS -l nodes=1:ppn=20
#PBS -N MOOSE_MECH


#  --------------------------------------------------------------------------------------------------
# Extract the command-line arguments
IMAGE_FILE="$1"  # The image file path is passed as the first argument
RESOLUTION="$2"

now1=$(date +"%T")
echo "Starting: $now1"

# Use the ls command to list the image files in the directory and store the results in an array
image_files=("$IMAGE_FILE")  # Use the specified image file
#  --------------------------------------------------------------------------------------------------
# Loop through the image files
for mesh_png in "${image_files[@]}"
do
	
	# loop through moose resolutions
	for moose_resolution in $RESOLUTION
	do

		export CC=mpicc
		export CXX=mpicxx
		export F90=mpif90
		export F77=mpif77
		export FC=mpif90

		# loading modules
		module purge
		module load devtoolset
		module load mpi/openmpi-4.1.2

		#openmpi path
		export PATH=/opt/ud/openmpi-4.1.2/bin:$PATH
		export C_INCLUDE_PATH=/opt/ud/openmpi-4.1.2/include:$C_INCLUDE_PATH
		export CPLUS_INCLUDE_PATH=/opt/ud/openmpi-4.1.2/include:$CPLUS_INCLUDE_PATH
		export FPATH=/opt/ud/openmpi-4.1.2/include:$FPATH
		export MANPATH=/opt/ud/openmpi-4.1.2/share/man:$MANPATH
		export LD_LIBRARY_PATH=/opt/ud/openmpi-4.1.2/lib:$LD_LIBRARY_PATH

		#setting up environment variables
		export STACK_SRC=/home/mreitberger/stack_src
		export PACKAGES_DIR=/home/everybody/moose/packages
		export MOOSE_DIR=/home/everybody/moose/moose

		export VTK_PREFIX=$PACKAGES_DIR/vtk-9.1.0/gcc-opt
		export VTKLIB_DIR=$VTK_PREFIX/lib64
		export VTKINCLUDE_DIR=$VTK_PREFIX/include/vtk-9.1.0
		export DYLD_LIBRARY_PATH=$VTKLIB_DIR:$DYLD_LIBRARY_PATH
		export LD_LIBRARY_PATH=$VTKLIB_DIR:$LD_LIBRARY_PATH

		export HDF5_DIR=$MOOSE_DIR/petsc/arch-moose/lib

		export EXECUTABLE=/home/everybody/moose/redback/redback-opt
		export SIMULATION_DIR=/home/htli/pipeline/MOOSE/simulation_dir
		export INPUT=compression_2D-elastic-image_reader
		export IMAGE=/home/htli/pipeline/porespy/images/$mesh_png
		export RESOLUTION=$moose_resolution
		# Keep every output file with specified name
		export OUTPUT_NAME=output_files/${mesh_png#*_resolution}${moose_resolution}



		echo "-> loop $mesh_png $moose_resolution started"

		export MOOSE_JOBS=4
		cd $SIMULATION_DIR
		
		# Write moose output to file moose_console_output.txt instead of the terminal. Note: the file's content is overwritten everytime the loop runs.
		mpiexec -np $MOOSE_JOBS $EXECUTABLE -i ${INPUT}.i Mesh/mesh/nx=$RESOLUTION Mesh/mesh/ny=$RESOLUTION Mesh/image/file=$IMAGE Outputs/file_base=${OUTPUT_NAME} > ./moose_console_output/moose_console_output.txt

		# Search for the line with '1.000000e+00' and extract the second numeric value
		max_vm_stress=$(grep "1.000000e+00" ./moose_console_output/moose_console_output.txt | awk -F'|' '{print $3}' | tr -d '[:space:]')
		echo "max_vm_stress = $max_vm_stress"

		# Write results to results file
		echo "$moose_resolution,$max_vm_stress,$mesh_png" >> ./max_VM_stress_results/max_VM_stress_results.txt
		echo "-> loop $mesh_png $moose_resolution completed"
		
		# Assuming $mesh_png contains the image name like "n1000_h4.0_p0.1_s3.png"
		# Use 'sed' to extract the "h" value
		h_value=$(echo "$mesh_png" | sed -n 's/.*h\([0-9.]\+\)_.*.png/\1/p')

		# Create the formatted result string
		result_string="h=$h_value, VM stress=$max_vm_stress"

		# Append the result to the results file
		echo "$result_string" >>./simple_result.txt

	done
	
done
# Add a seperation line
echo "-------------------end-------------------------------" >> ./max_VM_stress_results/max_VM_stress_results.txt
echo "-------------------end-------------------------------" >> ./simple_result.txt
now2=$(date +"%T")
echo "Ending: $now2"
