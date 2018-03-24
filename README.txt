Part 1 - Single Node MapReduce:

Open the part 1 directory and save the file or files you want to process in the files subdirectory (or create your own)
Use the command chmod u+x to make the scripts executable
Run the job_master_centralised.sh script with the directory name as argument. The syntax is as follows
./job_master_centralised.sh files
The count for each of the products will be displayed on the screen

Part 2 - Advanced Scenario and Analysis:

Open the part 2 directory and save the file or files you want to process in the files subdirectory (or create your own)
Use the command chmod u+x to make the scripts executable
Run the job_master_part2.sh script with the directory name and the number of the field you want to process as arguments.
For example the syntax for reading is as follows:
./job_master_part2.sh files 4
and field 2:
./job_master_part2.sh files 2
The count for each of the values in the field will be displayed on the screen

Part 3 - Distributed Solution:

Save the scripts in the local machine directory to one machine and the scripts in the distant machine to another.
Use the command chmod u+x to make the scripts executable
create a subdirectory on each machine called files (to use a directory of a different name you will need to change the code for master12751005.sh)
Run the master12751005.sh script on one machine and then the job_master.sh on the other. The order in which they are run is important.
The syntax is as follows:
On local machine: ./master12751005
On distant machine: ./job_master.sh

