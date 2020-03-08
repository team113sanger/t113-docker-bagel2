#! /bin/bash

set -xe

if [[ -z "${TMPDIR}" ]]; then
  TMPDIR=/tmp
fi

set -u

if [ "$#" -lt "1" ] ; then
  echo "Please provide an installation path such as /opt/ICGC"
  exit 1
fi

# get path to this script
SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

# get the location to install to
INST_PATH=$1
mkdir -p $1
INST_PATH=`(cd $1 && pwd)`
echo $INST_PATH

# get current directory
INIT_DIR=`pwd`

CPU=`grep -c ^processor /proc/cpuinfo`
if [ $? -eq 0 ]; then
  if [ "$CPU" -gt "6" ]; then
    CPU=6
  fi
else
  CPU=1
fi
echo "Max compilation CPUs set to $CPU"

SETUP_DIR=$INIT_DIR/install_tmp
mkdir -p $SETUP_DIR/distro # don't delete the actual distro directory until the very end
mkdir -p $INST_PATH/bin
cd $SETUP_DIR

# make sure tools installed can see the install loc of libraries
set +u
export LD_LIBRARY_PATH=`echo $INST_PATH/lib:$LD_LIBRARY_PATH | perl -pe 's/:\$//;'`
export LIBRARY_PATH=`echo $INST_PATH/lib:$LIBRARY_PATH | perl -pe 's/:\$//;'`
export C_INCLUDE_PATH=`echo $INST_PATH/include:$C_INCLUDE_PATH | perl -pe 's/:\$//;'`
export PATH=`echo $INST_PATH/bin:$PATH | perl -pe 's/:\$//;'`
export MANPATH=`echo $INST_PATH/man:$INST_PATH/share/man:$MANPATH | perl -pe 's/:\$//;'`
export PERL5LIB=`echo $INST_PATH/lib/perl5:$PERL5LIB | perl -pe 's/:\$//;'`
set -u

# numpy
if [ ! -e $SETUP_DIR/numpy.success ]; then
  pip3 install --no-deps --target=$INST_PATH/python3 numpy==${VER_NUMPY}
  touch $SETUP_DIR/numpy.success
fi

# scipy
if [ ! -e $SETUP_DIR/scipy.success ]; then
  pip3 install --no-deps --target=$INST_PATH/python3 scipy==${VER_SCIPY}
  touch $SETUP_DIR/scipy.success
fi

# pytz
if [ ! -e $SETUP_DIR/pytz.success ]; then
  pip3 install --no-deps --target=$INST_PATH/python3 pytz==${VER_PYTZ}
  touch $SETUP_DIR/pytz.success
fi

# python-dateutil
if [ ! -e $SETUP_DIR/python_dateutil.success ]; then
  pip3 install --no-deps --target=$INST_PATH/python3 python-dateutil==${VER_PYTHON_DATEUTIL}
  touch $SETUP_DIR/python_dateutil.success
fi

# six
if [ ! -e $SETUP_DIR/six.success ]; then
  pip3 install --no-deps --target=$INST_PATH/python3 six==${VER_SIX}
  touch $SETUP_DIR/six.success
fi

# pandas
if [ ! -e $SETUP_DIR/pandas.success ]; then
  pip3 install --no-deps --target=$INST_PATH/python3 pandas==${VER_PANDAS}
  touch $SETUP_DIR/pandas.success
fi

# click
if [ ! -e $SETUP_DIR/click.success ]; then
  pip3 install --no-deps --target=$INST_PATH/python3 click==${VER_CLICK}
  touch $SETUP_DIR/click.success
fi

# joblib
if [ ! -e $SETUP_DIR/joblib.success ]; then
  pip3 install --no-deps --target=$INST_PATH/python3 joblib==${VER_JOBLIB}
  touch $SETUP_DIR/joblib.success
fi

# scikit-learn
if [ ! -e $SETUP_DIR/scikit-learn.success ]; then
  pip3 install --no-deps --target=$INST_PATH/python3 scikit-learn==${VER_SCIKIT_LEARN}
  touch $SETUP_DIR/scikit-learn.success
fi

# BAGEL
if [ ! -e $SETUP_DIR/bagel.success ]; then
  BAGEL_INST_DIR=$INST_PATH/bagel
  mkdir $BAGEL_INST_DIR
  
  git clone https://github.com/hart-lab/bagel.git ${BAGEL_INST_DIR}
  cd ${BAGEL_INST_DIR}
  git reset --hard ${VER_BAGEL_COMMIT}
  ln -s $BAGEL_INST_DIR/*.py $INST_PATH/bin

  cd $SETUP_DIR
  touch $SETUP_DIR/bagel.success
fi
