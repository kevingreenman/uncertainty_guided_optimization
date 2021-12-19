export DIR="$(dirname "$(pwd)")"
#conda env update --file ${DIR}'/uncertainty_guided_env.yml'
source activate uncertainty_guided_env
export PYTHONPATH=${PYTHONPATH}:${DIR}

python ../JTVAE/fast_molvae/data_preprocess.py \
                --train ${DIR}'/JTVAE/data/uvvis/20211218_all_dye_smiles.txt' \
                --split 100 --jobs 40 \
                --output ${DIR}'/JTVAE/data/uvvis_processed'
