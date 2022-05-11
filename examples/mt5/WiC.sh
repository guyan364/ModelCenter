#! /bin/bash

MASTER_ADDR=localhost
MASTER_PORT=12345
NNODES=1
NODE_RANK=0
GPUS_PER_NODE=4

DISTRIBUTED_ARGS="--nproc_per_node $GPUS_PER_NODE \
                  --nnodes $NNODES \
                  --node_rank $NODE_RANK \
                  --master_addr $MASTER_ADDR \
                  --master_port $MASTER_PORT"

BASE_PATH="/home/hx/ModelCenter"
VERSION="xxl"
DATASET="WiC"

OPTS=""
OPTS+=" --dataset ${DATASET}"
OPTS+=" --base-path ${BASE_PATH}"
OPTS+=" --model-config t5-v1_1-${VERSION}"
OPTS+=" --batch-size 16"
OPTS+=" --train-iters 1500"
OPTS+=" --save-iters 1000"
OPTS+=" --max-encoder-length 512"
OPTS+=" --max-decoder-length 2"
OPTS+=" --save ${BASE_PATH}/results"
OPTS+=" --save-name finetune-t5-v1_1-ckpt"
OPTS+=" --lr 0.00001"
OPTS+=" --inspect-iters 100"
OPTS+=" --warmup-iters 70"
OPTS+=" --lr-decay-style constant"
OPTS+=" --weight-decay 1e-2"
OPTS+=" --clip-grad 100.0"
OPTS+=" --loss-scale 128"
# OPTS+=" --load ${BASE_PATH}/results/t5-v1_1-${VERSION}.pt"

CMD="python3 -m torch.distributed.launch ${DISTRIBUTED_ARGS} ${BASE_PATH}/examples/t5-v1_1/finetune_t5-v1_1.py ${OPTS}"
echo ${CMD}

${CMD} 2>&1 | tee ${BASE_PATH}/logs/t5-v1_1_superglue/finetune-t5-v1_1-${VERSION}-${DATASET}.log
