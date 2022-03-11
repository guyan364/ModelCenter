#! /bin/bash

if [[ $DLS_TASK_NUMBER == 1 ]]; then
    MASTER_ADDR=localhost
    MASTER_PORT=$(shuf -n 1 -i 10000-65535)
    NNODES=1
    NODE_RANK=0
else
    MASTER_HOST="$BATCH_CUSTOM0_HOSTS"
    MASTER_ADDR="${MASTER_HOST%%:*}"
    MASTER_PORT="${MASTER_HOST##*:}"
    NNODES="$DLS_TASK_NUMBER"
    NODE_RANK="$DLS_TASK_INDEX"
fi

GPUS_PER_NODE=4

DISTRIBUTED_ARGS="--nproc_per_node $GPUS_PER_NODE \
                  --nnodes $NNODES \
                  --node_rank $NODE_RANK \
                  --master_addr $MASTER_ADDR \
                  --master_port $MASTER_PORT"

BASE_PATH="/home/hx/cpm3-pretrain"
VERSION="11b"
DATASET="COPA"

OPTS=""
OPTS+=" --dataset ${DATASET}"
OPTS+=" --base-path ${BASE_PATH}"
OPTS+=" --model-config ${BASE_PATH}/src/config/t5/t5-${VERSION}.json"
OPTS+=" --batch-size 4"
OPTS+=" --train-iters 900"
OPTS+=" --save-iters 1000"
OPTS+=" --max-encoder-length 512"
OPTS+=" --max-decoder-length 2"
OPTS+=" --save ${BASE_PATH}/results"
OPTS+=" --save-name finetune-t5-ckpt"
OPTS+=" --lr 0.00001"
OPTS+=" --inspect-iters 100"
OPTS+=" --warmup-iters 40"
OPTS+=" --lr-decay-style noam"
OPTS+=" --weight-decay 1e-2"
OPTS+=" --clip-grad 1.0"
OPTS+=" --loss-scale 128"
OPTS+=" --load ${BASE_PATH}/results/T5-${VERSION}.pt"

CMD="python3 -m torch.distributed.launch ${DISTRIBUTED_ARGS} ${BASE_PATH}/src/finetune_t5.py ${OPTS}"
echo ${CMD}

${CMD} 2>&1 | tee ${BASE_PATH}/logs/t5_superglue/finetune-t5-${VERSION}-${DATASET}.log
