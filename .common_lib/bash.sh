
export BASH=bash
export CONFIG_BASH_VERSION=4.3
export BASH_VERSION=${BASH}-${CONFIG_BASH_VERSION}
export BASH_OUTPUT_PATH=${OUTPUT_PATH}/bash
export BASH_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/bash

function download_bash () {
    _sync_export_var_bash
    #tget    https://ftp.gnu.org/gnu/bash/bash-5.1.8.tar.gz
    tget    https://ftp.gnu.org/gnu/bash/bash-${CONFIG_BASH_VERSION}.tar.gz
}

function _sync_export_var_bash()
{
    export BASH_VERSION=${BASH}-${CONFIG_BASH_VERSION}
}

function mk_bash () {

    local build_for_host="$1" # say y for host

    _sync_export_var_bash
    local build_with_target_arch_cmd_part=""
    local cache_file_path_cmd_part=""
    local output_dir=""
    if [  "$build_for_host" == 'y' ];then
        cache_file_path_cmd_part="--cache-file=host.cache"
        build_with_target_arch_cmd_part=""
        output_dir=${BASH_OUTPUT_PATH_HOST}
    else
        cache_file_path_cmd_part="--cache-file=arm-linux.cache"
        build_with_target_arch_cmd_part="--host=arm-linux  CC=\"${_CC}\""
        output_dir=${BASH_OUTPUT_PATH}
    fi

    bash <<EOF

    cd ${CODE_PATH}/$BASH_VERSION

    ./configure ${build_with_target_arch_cmd_part} \
        --prefix=${output_dir} \
        --enable-history \
        --without-bash-malloc  \
        ${cache_file_path_cmd_part}
    make clean
    make $MKTHD && make install
EOF
}

function echo_bash_help ()
{
    cat <<EOF
ok
-------------安装-------------
1. 将 install/bin中的 bash 文件复制至开发板 /bin 中
2. 修改 开发板中 /bin/bash 权限 : "chmod +x /bin/bash"
3. 执行 "val1=15; val2=1; and=\$[ \$val1 & \$val2 ]; echo \$and"，理论上ash会有错误产生
4. 输入bash，再执行上面的命令，预期正确的打印

-------------默认-------------
1. 备份原有的sh: "cd /bin; mv sh sh.old"
2. 修改: "ln -s bash sh"
EOF
}

function make_bash ()
{
    _sync_export_var_bash
    download_bash  || return 1
    tar_package || return 1

    mk_bash  || return 1
    echo_bash_help
}

function make_bash_host ()
{
    _sync_export_var_bash
    download_bash  || return 1
    tar_package || return 1

    mk_bash y || return 1
    echo_bash_help
}

