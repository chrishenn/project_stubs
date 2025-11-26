#!/bin/bash
set -e -u -x

function repair_wheel {
	wheel="$1"
	if ! auditwheel show "$wheel"; then
		echo "Skipping non-platform wheel $wheel"
	else
		auditwheel repair "$wheel" --plat "$PLAT" -w /io/wheelhouse/
	fi
}

# Install system packages we depend on

# Install Cudnn
## for manylinux2014 which is Centos7 based
## ameli/manylinux-cuda includes cuda 11.4 but these packages are built with 11.6
OS=rhel7
cudnn_version=8.4.0.27
cuda_version=cuda11.6

# TODO: local install
#  won't install from local file in isolated env, even though file is accessible
# Complians about outdated/mismatched package pgp keys - maybe update the nvidia repo and then local install?

#rpm -i /home/chris/Documents/cudnn-local-repo-$OS-$cudnn_version-1.0-1.x86_64.rpm
#yum clean all
#yum install -y libcudnn8-$cudnn_version-1.$cuda_version
#yum install -y libcudnn8-devel-$cudnn_version-1.$cuda_version

# Online install
yum-config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/$OS/x86_64/cuda-$OS.repo
yum clean all
yum install -y libcudnn8-$cudnn_version-1.$cuda_version
yum install -y libcudnn8-devel-$cudnn_version-1.$cuda_version

# Compile wheels against various python versions
declare -a StringArray=(
	"/opt/python/cp36-cp36m/bin"
	"/opt/python/cp37-cp37m/bin"
	"/opt/python/cp38-cp38/bin"
	"/opt/python/cp39-cp39/bin"
	"/opt/python/cp310-cp310/bin"
)

for PYBIN in $StringArray[@]; do
	"${PYBIN}/pip" wheel /io/ --no-deps -w wheelhouse/
done

## TODO: Why? Some of these binaries (like 'pypy36-something') I don't recognize, and they fail.
#for PYBIN in /opt/python/*/bin; do
#  "${PYBIN}/pip" install -r /io/dev-requirements.txt
#  "${PYBIN}/pip" wheel /io/ --no-deps -w wheelhouse/
#done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
	repair_wheel "$whl"
done

## Testing for Travis-CI
# Install packages and test
# for PYBIN in /opt/python/*/bin/; do
#     "${PYBIN}/pip" install python-manylinux-demo --no-index -f /io/wheelhouse
#     (cd "$HOME"; "${PYBIN}/nosetests" pymanylinuxdemo)
# done
