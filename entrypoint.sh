#!/bin/bash

PYTHON_VENV_PATH="./.venv"
PYTHON_REQUIREMENTS="./requirements.txt"

echo "Running entrypoint script..."

if [ -z "${1}" ] && [ -z "${CONTAINER_PORT+x}" ];
then 
	export CONTAINER_PORT=8888
elif [ ! -z "${1}" ];
then
	export CONTAINER_PORT="${1}"
fi

if [ -z "${2}" ] && [ -z "${ENTER_VENV+x}" ];
then 
	export ENTER_VENV=true
elif [ ! -z "${2}" ];
then
	export ENTER_VENV=false
fi

# Check if python virtual env and use it
# or create it and install stuff otherwise
if [ "${ENTER_VENV}" = "true" ] && test -f "${PYTHON_VENV_PATH}/bin/activate"; then
  echo "VENV exists"
  . ${PYTHON_VENV_PATH}/bin/activate
elif [ "${ENTER_VENV}" = "true" ]; then
  echo "Create VENV"
  python -m venv ${PYTHON_VENV_PATH}
  . ${PYTHON_VENV_PATH}/bin/activate
  python -m pip install -r ${PYTHON_REQUIREMENTS}
else
  echo "No VENV"
fi

# old notebook interface:
#jupyter notebook --ip "0.0.0.0" --port ${CONTAINER_PORT}

# new lab interface:
jupyter-lab --ip "0.0.0.0" --port ${CONTAINER_PORT}

# or alternatively and endless loop
# maybe one in the background and one inte foreground:
#while true; do sleep 15 ; echo "background"; done &
#while true; do sleep 12 ; echo "foreground"; done
