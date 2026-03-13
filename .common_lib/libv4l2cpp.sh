LIBV4L2CPP=libv4l2cpp
export LIBV4L2CPP_VERSION=${LIBV4L2CPP}

export LIBV4L2CPP_OUTPUT_PATH=${OUTPUT_PATH}/${LIBV4L2CPP}
export LIBV4L2CPP_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${LIBV4L2CPP}

function get_libv4l2cpp () {
    tgit https://github.com/mpromonet/libv4l2cpp
}

function mk_libv4l2cpp () {
    mkdir ${CODE_PATH}/ -p
	local host_build=$1
	local output_path=""
	local cc_arg=""

	if [ -z "$host_build" ]; then
		output_path=$LIBV4L2CPP_OUTPUT_PATH
		cc_arg="-DCMAKE_CXX_COMPILER=${BUILD_HOST_}g++ -DCMAKE_C_COMPILER=${BUILD_HOST_}gcc"
	else
		output_path=$LIBV4L2CPP_OUTPUT_PATH_HOST
		cc_arg=""
	fi

    cd ${CODE_PATH}/${LIBV4L2CPP_VERSION}
(
cat <<EOF
	TOP_DIR=\`pwd\`
	rm build -rf
	mkdir build -p

	cd build
	cmake .. $cc_arg

	make $MKTHD || exit 1

	cd \$TOP_DIR

	mkdir -p $output_path
	mkdir -p $output_path/include
	mkdir -p $output_path/lib
	mkdir -p $output_path/bin

	cp -rf inc/*                 $output_path/include
	cp -rf build/liblibv4l2cpp.a $output_path/lib
	cp -rf build/libv4l2cpptest  $output_path/bin
EOF
) > .build${host_build}.sh
	bash .build${host_build}.sh
}

function make_libv4l2cpp () {
    get_libv4l2cpp
    tar_package       || return 1
    mk_libv4l2cpp
}

function make_libv4l2cpp_host () {
    get_libv4l2cpp
    tar_package       || return 1
    mk_libv4l2cpp "host"
}
