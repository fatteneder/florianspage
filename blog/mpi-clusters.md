@def title="Minimal project to test MPI with Slurm queue"
@def published="27 April 2024"


# A minimal project to test `MPI` support on a `Slurm` managed cluster

Here is a minimal `C` program, together with a job script that can be used
to test a `MPI hello world` program on a `Slurm` managed cluster.
Below we provide configs and batch scripts that utilize the `test` partitions of the following
supercomputers or clusters:
- `SUPERMUC-NG` @ LRZ Munich: [docs](https://doku.lrz.de/using-supermuc-ng-11482518.html)
- `ARA` @ FSU Jena: [docs](https://ara-wiki.rz.uni-jena.de/Hauptseite)

---

## Instructions

1. Copy the below files `mwe.c, mwe.job, Makefile, moduleinit.sh` into a folder `mwe` in your home directory on the cluster.
2. Update `moduleinit.sh` and replace the fields `<your-email-address>,<project-account-name>,<username>` accordingly.
3. Run
```sh
cd mwe
source moduleinit.sh # make sure that the output directory specified here actually exists on disk
make
sbatch mwe.job
```
4. Wait till your job completes (check with `squeue -u "<username>" -i 10`).
5. Observe the output in the respective output folder.

---

`mwe.c`
```c
#include <mpi.h>
#include <stdio.h>

// from https://mpitutorial.com/tutorials/mpi-hello-world/
int main(int argc, char** argv) {
    // Initialize the MPI environment
    MPI_Init(NULL, NULL);

    // Get the number of processes
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // Get the rank of the process
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // Get the name of the processor
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    // Print off a hello world message
    printf("Hello world from processor %s, rank %d out of %d processors\n",
           processor_name, world_rank, world_size);

    // Finalize the MPI environment.
    MPI_Finalize();
}
```

`Makefile`
```
all:
    mpicc mwe.c -o mwe
```

`moduleinit.sh` (for SUPERMUC-NG)
```bash
#!/usr/bin/env bash

module load slurm_setup
module load intel-oneapi-compilers/2021.4.0
```

`moduleinit.sh` (for ARA)
```bash
#!/usr/bin/env bash

module load mpi/openmpi/4.1.2-gcc-10.2.0
```

`mwe.job` (for SUPERMUC-NG)
```bash
#!/usr/bin/env bash
#SBATCH --time=0-0:30:00
#SBATCH --job-name=mwe
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=<your-email-address>
#SBATCH --output=/hppfs/scratch/00/<username>/mwe.out
#SBATCH --error=/hppfs/scratch/00/<username>/mwe.err
#SBATCH --partition=test
#SBATCH --nodes=2
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --ntasks-per-core=1
#SBATCH --no-requeue
#SBATCH --account=<project-account-name>
#SBATCH --get-user-env
#SBATCH --export=NONE

# /hppfs/scratch/00/<username> is the working partition
# /dss/dsshome1/00/<username> is my home directory
source /dss/dsshome1/00/<username>/mwe/moduleinit.sh
mpiexec /dss/dsshome1/00/<username>/mwe/mwe
```

`mwe.job` (for ARA)
```bash
#!/usr/bin/env bash
#SBATCH --time=0-0:30:00
#SBATCH --job-name=mwe
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=<your-email-address>
#SBATCH --output=/beegfs/<username>/mwe.out
#SBATCH --error=/beegfs/<username>/mwe.err
#SBATCH --partition=s_test
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --ntasks-per-node=12
#SBATCH --ntasks-per-core=1
#SBATCH --no-requeue

# /beegfs is the working partition
source /home/<username>/mwe/moduleinit.sh
mpirun /home/<username>/mwe/mwe
```
