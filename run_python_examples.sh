#!/usr/bin/env bash
#
# This script runs through the code in each of the python examples.
# The purpose is just as an integration test, not to actually train models in any meaningful way.
# For that reason, most of these set epochs = 1 and --dry-run.
#
# Optionally specify a comma separated list of examples to run.
# can be run as:
# ./run_python_examples.sh "install_deps,run_all,clean"
# to pip install dependencies (other than pytorch), run all examples, and remove temporary/changed data files.
# Expects pytorch, torchvision to be installed.

BASE_DIR="$(pwd)/$(dirname $0)"
source $BASE_DIR/utils.sh

USE_CUDA=$(python -c "import torchvision, torch; print(torch.cuda.is_available())")
case $USE_CUDA in
  "True")
    echo "using cuda"
    CUDA=1
    CUDA_FLAG="--cuda"
    ;;
  "False")
    echo "not using cuda"
    CUDA=0
    CUDA_FLAG=""
    ;;
  "")
    exit 1;
    ;;
esac


function mnist() {
  start
  python main.py --epochs 1 --dry-run || error "mnist example failed"
}

function clean() {
  cd $BASE_DIR
  echo "running clean to remove cruft"
}

function run_all() {
  mnist
}

# by default, run all examples
if [ "" == "$EXAMPLES" ]; then
  run_all
else
  for i in $(echo $EXAMPLES | sed "s/,/ /g")
  do
    echo "Starting $i"
    $i
    echo "Finished $i, status $?"
  done
fi

if [ "" == "$ERRORS" ]; then
  echo "Completed successfully with status $?"
else
  echo "Some python examples failed:"
  printf "$ERRORS\n"
  #Exit with error (0-255) in case of failure in one of the tests.
  exit 1

fi
