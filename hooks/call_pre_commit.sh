#!/bin/env bash
declare -a filescommit
declare -a arraypath
levellog="debug"
path=$(pwd)
if [ "$levellog" == "debug" ]; then echo "path: $path"; fi
path=${path/.git\/hooks/}

if [ -d "$path.git" ]; then
    if [ "$levellog" == "debug" ]; then echo "eq0: $path"; fi
else
    path="$path/"
    if [ "$levellog" == "debug" ]; then echo "ne0: $path"; fi
fi


function get_commit {
    if [ "$levellog" == "debug" ]; then echo "function get_commit:"; fi
    filescommit=($(git log -1 --oneline --name-only | grep "/"))

    # if [ "$levellog" == "debug" ]; then echo "Values array filescommit:"; fi
    # n=0
    # for i in "${filescommit[@]}"; do
    #     echo "Valor $n: $i";
    #     let "n+=1"
    # done
}

function create_array_path {
    if [ "$levellog" == "debug" ]; then echo "function create_array_path:"; fi
    for i in "${filescommit[@]}"; do
        #echo "Valor: $i";
        path_pre_commit=$(echo "$(dirname "${i}")") ;
        #echo "Path: $path_pre_commit"

        # len=$(echo "${#arraypath[@]}")
        # #echo "Valor de len: $len"
        # if [ "$len" -eq 0 ]; then
        #     arraypath+="$path_pre_commit"
        #     #echo "Primer elemento: ${arraypath[0]}"
        # fi

        local needle="$path_pre_commit"
        printf "%s\n" ${arraypath[@]} | grep -q "^$needle$"
        if [ $? -ne 0 ];then
            #echo "path_pre_commit: ${path_pre_commit}.pre-commit-config.yaml"
            if [ -f ${path_pre_commit}/.pre-commit-config.yaml ]; then
                #echo "Sí, el fiechero existe."
                arraypath+=("${path_pre_commit}")
            fi
        fi
    done

    # echo "Values arraypath "
    # for i in "${arraypath[@]}"; do
    #     echo "Valor: $i";
    # done
}

function precommit {
    echo "function precommit:"
    
    #echo "$path"
    for i in "${arraypath[@]}"; do
        echo "pre-commit: $i";
        cd $path
        cd $i
        pre-commit run -a
    done
}


get_commit
create_array_path
precommit
#ROOT_COMMIT=$(get_commit)
#SUBDIR_COMMIT=$(get_commit my/subdir/path)
#export VAR='/home/pax/file.c'
# path_pre_commit=$(echo "$(dirname "${ROOT_COMMIT}")") ;
# file_pre_commit=$(echo "$(basename "${ROOT_COMMIT}")");

# if [ "$SUBDIR_COMMIT" == "$ROOT_COMMIT" ]; then
#     # do pre-commit hook stuff here
# fi

# if [ ! -z "$path_pre_commit" ]; then
#     cd $path_pre_commit
#     pre-commit run -a
# fi