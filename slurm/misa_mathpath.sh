#!/bin/bash
#SBATCH -e /data/users3/oyohannes1/MISA-pytorch/slurm_logs/error%A-%a.err
#SBATCH -o /data/users3/oyohannes1/MISA-pytorch/slurm_logs/out%A-%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=oyohannes1@student.gsu.edu
#SBATCH --chdir=/data/users3/oyohannes1/MISA-pytorch
#
#SBATCH -p qTRDGPUH
#SBATCH --gres=gpu:V100:1
#SBATCH --account=trends53c17
#SBATCH --job-name=MISAtorch
#SBATCH --verbose
#SBATCH --time=7200
#
#SBATCH --nodes=1
#SBATCH --mem=90g
#SBATCH --cpus-per-task=10


sleep 5s
hostname
source ~/.bashrc
. ~/init_miniconda3.sh
conda activate pt2

seed=(7 14 21)
w=('wpca' 'w0' 'w1')

SEED=${seed[$((SLURM_ARRAY_TASK_ID % 3))]}
echo $SEED
W=${w[$((SLURM_ARRAY_TASK_ID / 3))]}
echo $W
declare -i n_dataset=100
declare -i n_source=12
declare -i n_sample=32768
lrs=(0.001 0.100 0.001 0.100 0.010 0.010 0.100)

batch_size=(100 100 100 1000 1000 316 1000)
patience=(10.0 100.0 10.0 10.0 100.0 32.0 32.0)

#Adam optimizer parameters
foreach=(1 0 0 1 1 1 0)
fused=(0 0 1 0 1 1 1)
beta1=(0.65 0.80 0.95 0.65 0.95 0.80 0.65)
beta2=(0.99 0.81 0.81 0.81 0.99 0.90 0.99)

experimenter="$USER"
configuration="/data/users3/oyohannes1/MISA-pytorch/configs/sim-siva.yaml"

data_file="sim-siva_dataset"$n_dataset"_source"$n_source"_sample"$n_sample"_seed"$SEED".mat"
declare -i num_experiments=${#lrs[@]}
for ((i=0; i<num_experiments; i++)); do
    python main.py -c "$configuration" -f "$data_file" -r results/MathPath2024/ -w "$W" -a -lr "${lrs[$i]}" -b1 "${beta1[$i]}" -b2 "${beta2[$i]}" -bs "${batch_size[$i]}" -e "$experimenter" -fu "${fused[$i]}" -fo "${foreach[$i]}" -p "${patience[$i]}" -s "$SEED"
    sleep 5s
done