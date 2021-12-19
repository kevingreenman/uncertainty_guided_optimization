#!/bin/bash
#SBATCH -p normal
#SBATCH -J decoder_unc_uvvis
#SBATCH -o decoder_unc_uvvis-%j.out
#SBATCH -t 10-00:00:00
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem=50gb
#SBATCH --gres=gpu:volta:1

echo "Date              = $(date)"
echo "Hostname          = $(hostname -s)"
echo "Working Directory = $(pwd)"
echo ""
cat $0
echo ""

source /etc/profile
module load anaconda/2021b
source activate uncertainty_guided_env

## Preprocess the data
echo "STARTING SCRIPT JTVAE_data_preprocess.sh"
start_time=$SECONDS
bash JTVAE_data_preprocess.sh
elapsed=$(( SECONDS - start_time ))
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"

## Generate a new vocabulary on new dataset
echo "STARTING SCRIPT JTVAE_data_vocab_generation.sh"
start_time=$SECONDS
bash JTVAE_data_vocab_generation.sh
elapsed=$(( SECONDS - start_time ))
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"

## Train the JTVAE networks:

## JTVAE with no auxiliary property network
#echo "STARTING SCRIPT JTVAE_train_jtnnvae.sh"
#start_time=$SECONDS
#bash JTVAE_train_jtnnvae.sh
#elapsed=$(( SECONDS - start_time ))
#eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"

# JTVAE with auxiliary property network
echo "STARTING SCRIPT JTVAE_train_jtnnvae-prop_step1_pretrain.sh" 
start_time=$SECONDS
bash JTVAE_train_jtnnvae-prop_step1_pretrain.sh # to pre-train the joint architecture (with no KL term in the loss)
elapsed=$(( SECONDS - start_time ))
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"

echo "STARTING SCRIPT JTVAE_train_jtnnvae-prop_step2_train.sh"
start_time=$SECONDS
bash JTVAE_train_jtnnvae-prop_step2_train.sh # to train the joint architecture
elapsed=$(( SECONDS - start_time ))
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"

## Test the quality of trained JTVAE networks

#echo "STARTING SCRIPT JTVAE_test_jtnnvae.sh"
#start_time=$SECONDS
#bash JTVAE_test_jtnnvae.sh
#elapsed=$(( SECONDS - start_time ))
#eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"

echo "STARTING SCRIPT JTVAE_test_jtnnvae-prop.sh"
start_time=$SECONDS
bash JTVAE_test_jtnnvae-prop.sh
elapsed=$(( SECONDS - start_time ))
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"

## Perform uncertainty-guided optimization in latent:

echo "STARTING SCRIPT JTVAE_uncertainty_guided_optimization_gradient_ascent.sh"
start_time=$SECONDS
bash JTVAE_uncertainty_guided_optimization_gradient_ascent.sh # Gradient ascent
elapsed=$(( SECONDS - start_time ))
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"

echo "STARTING SCRIPT JTVAE_uncertainty_guided_optimization_bayesian_optimization.sh"
start_time=$SECONDS
bash JTVAE_uncertainty_guided_optimization_bayesian_optimization.sh # Bayesian optimization
elapsed=$(( SECONDS - start_time ))
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"
