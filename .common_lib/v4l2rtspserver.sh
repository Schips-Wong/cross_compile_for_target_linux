V4L2RTSPSERVER=v4l2rtspserver
export CONFIG_V4L2RTSPSERVER_VERSION=master
export V4L2RTSPSERVER_VERSION=${V4L2RTSPSERVER}-${CONFIG_V4L2RTSPSERVER_VERSION}

export V4L2RTSPSERVER_OUTPUT_PATH=${OUTPUT_PATH}/${V4L2RTSPSERVER}
export V4L2RTSPSERVER_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${V4L2RTSPSERVER}

function get_v4l2rtspserver () {
	get_live555
    #tgit_with_submod https://github.com/mpromonet/v4l2rtspserver
    tgit_with_bracnch_and_submod https://github.com/mpromonet/v4l2rtspserver $CONFIG_V4L2RTSPSERVER_VERSION
}

function mk_v4l2rtspserver () {
    mkdir ${CODE_PATH}/ -p
	local host_build=$1
	local output_path=""
	local cc_arg=""

	if [ -z "$host_build" ]; then
		output_path=$V4L2RTSPSERVER_OUTPUT_PATH
		cc_arg="-DCMAKE_CXX_COMPILER=${BUILD_HOST_}g++ -DCMAKE_C_COMPILER=${BUILD_HOST_}gcc"
	else
		output_path=$V4L2RTSPSERVER_OUTPUT_PATH_HOST
		cc_arg=""
	fi

    cd ${CODE_PATH}/${V4L2RTSPSERVER_VERSION}
(
cat <<EOF
	TOP_DIR=\`pwd\`
	rm build -rf
	mkdir build -p

	export PKG_CONFIG_PATH=${output_path}/lib/pkgconfig
	export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${output_path}/lib


	cp CMakeLists.txt.ori CMakeLists.txt
	cp CMakeLists.txt CMakeLists.txt.ori
	cat CMakeLists.txt.ori | grep -v "set(LIVE " > CMakeLists.txt
	cd build

	cmake .. $cc_arg  -DLIVE=${CODE_PATH}/live

	make $MKTHD || exit 1


	cd \$TOP_DIR

	mkdir -p $output_path
	mkdir -p $output_path/include
	mkdir -p $output_path/lib
	mkdir -p $output_path/bin

	cp -rf inc/*                   $output_path/include
	cp -rf \`find . -name '*.a'\`  $output_path/lib
	cp -rf build/v4l2rtspserver    $output_path/bin
EOF
) > .build${host_build}.sh
	bash .build${host_build}.sh
}

function make_v4l2rtspserver () {
    get_v4l2rtspserver
    tar_package       || return 1
	make_openssl
    mk_v4l2rtspserver
}

function make_v4l2rtspserver_host () {
    get_v4l2rtspserver
    tar_package       || return 1
	make_ssl_host
    mk_v4l2rtspserver "host"
}

