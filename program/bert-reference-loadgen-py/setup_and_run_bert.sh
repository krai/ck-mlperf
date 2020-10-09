#!/bin/sh

## Usually program's tmp/
#
CWD=`pwd`

export BERT_REF_ROOT=${CK_ENV_MLPERF_INFERENCE}/language/bert
export BERT_BUILD=${CWD}/build
export BERT_BUILD_DATA=${BERT_BUILD}/data

## CWD takes priority over the original code, because we patch some of the original files and retain them in CWD:
#
export PYTHONPATH=${PYTHONPATH}:${CWD}:${BERT_REF_ROOT}:${BERT_REF_ROOT}/DeepLearningExamples/TensorFlow/LanguageModeling/BERT


if [ ! -e "$BERT_BUILD" ]; then
    echo "Build directory does not exist yet"

    mkdir $BERT_BUILD

    if [ -n "$CK_BERT_DATA" ]; then
        echo "Given the following path to be used as build directory: $CK_BERT_DATA"
        if [ ! -e "$CK_BERT_DATA" ]; then
            echo "It did not exist, creating it..."
            mkdir $CK_BERT_DATA
        fi
        ln -s $CK_BERT_DATA $BERT_BUILD/data
    else
        echo "Not given a path for build directory, creating $BERT_BUILD ... Beware, it may take a lot of space!"
        mkdir $BERT_BUILD/data
    fi
    ln -s $CWD ${BERT_BUILD}/logs
    ln -s $CWD ${BERT_BUILD}/result
fi


cp ${BERT_REF_ROOT}/bert_config.json $CWD
cp ${BERT_REF_ROOT}/user.conf $CWD

git -C $BERT_REF_ROOT submodule update --init DeepLearningExamples
make -f ${BERT_REF_ROOT}/Makefile download_data
make -f ${BERT_REF_ROOT}/Makefile download_model


## A link for our convenience (not used by the scripts) :
#
rm -f ${CWD}/bert_code
ln -s ${BERT_REF_ROOT} ${CWD}/bert_code

## Patching some of BERT's scripts:
#
sed 's/ accuracy-squad.py/ .\/accuracy-squad.py/g' ${BERT_REF_ROOT}/run.py >${CWD}/run.py

## Adding one line to a Python script without disrupting the indentation structure:
#
EXTRA_LINE="if os.environ.get('CK_BERT_TRANSFORMERS_OVERRIDE','no').lower() in ('yes','on','true','1'): self.model.bert.set_weights_split()"
sed "/^([\ \t]*)self.model.load_state_dict/a \1${EXTRA_LINE}" ${BERT_REF_ROOT}/pytorch_SUT.py >${CWD}/pytorch_SUT.py

rm -rf ${CWD}/utils
mkdir ${CWD}/utils
cp ${BERT_REF_ROOT}/create_squad_data.py ${CWD}/utils/create_squad_data.py

## Run the patched version of run.py:
#
$CK_ENV_COMPILER_PYTHON_FILE ${CWD}/run.py --mlperf_conf=${CK_ENV_MLPERF_INFERENCE}/mlperf.conf --user_conf=${BERT_REF_ROOT}/user.conf --backend=${CK_BERT_BACKEND} --scenario=${CK_LOADGEN_SCENARIO} $CK_LOADGEN_MODE_STRING