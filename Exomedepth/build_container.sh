module load StdEnv/2023 apptainer/1.2.4

apptainer build --sandbox /home/liulang/scratch/soft/ExomeDepthSandbox docker://euformatics/exomedepth:v1.1
apptainer shell /home/liulang/scratch/soft/ExomeDepthSandbox
apptainer build --sandbox /home/liulang/scratch/soft/ExomeDepthSandbox docker://euformatics/exomedepth:v1.1
