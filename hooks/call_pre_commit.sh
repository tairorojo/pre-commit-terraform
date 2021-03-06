#!/bin/env bash
set -euo pipefail

declare -a filescommit
declare -a arraypath

paths=($@)

#levellog="debug"
if [ "$1" == "debug" ]; then
    levellog="debug"
else
    levellog="null"
fi

path=$(pwd)
if [ "$levellog" == "debug" ]; then echo "path: $path"; fi
path=${path/.git\/hooks/}

if [ -d "$path.git" ]; then
    if [ "$levellog" == "debug" ]; then echo "eq0: $path"; fi
else
    path="$path/"
    if [ "$levellog" == "debug" ]; then echo "ne0: $path"; fi
fi

if [ "$levellog" == "debug" ]; then echo "PWD: $(pwd)"; fi
if [ "$levellog" == "debug" ]; then echo "Path: $path"; fi


function get_commit {

    if [ "$levellog" == "debug" ]; then echo "function get_commit:"; fi
    #filescommit=($(git log -1 --oneline --name-only | grep "/"))
    filescommit=($(git diff --diff-filter=d --cached --name-only | grep "env" | grep "/"))

    if [ "$levellog" == "debug" ]; then echo "Values array filescommit:"; fi
    n=0
    for i in "${filescommit[@]}"; do
        if [ "$levellog" == "debug" ]; then echo "Valor $n: $i"; fi
        let "n+=1"
    done
}

function create_array_path {
    if [ "$levellog" == "debug" ]; then echo "function create_array_path:"; fi
    for i in "${filescommit[@]}"; do
        #echo "Valor: $i";
        path_pre_commit=$(echo "$(dirname "${i}")") ;
        if [ "$levellog" == "debug" ]; then echo "Path: $path_pre_commit"; fi

        # len=$(echo "${#arraypath[@]}")
        # #echo "Valor de len: $len"
        # if [ "$len" -eq 0 ]; then
        #     arraypath+="$path_pre_commit"
        #     #echo "Primer elemento: ${arraypath[0]}"
        # fi

        local needle="$path_pre_commit"
        set +euo pipefail
        printf "%s\n" ${arraypath[@]} | grep -q "^$needle$"
        if [ $? -ne 0 ];then
            if [ "$levellog" == "debug" ]; then echo "path_pre_commit: ${path_pre_commit}/.pre-commit-config.yaml"; fi
            if [ -f ${path_pre_commit}/.pre-commit-config.yaml ]; then
                #echo "Sí, el fiechero existe."
                arraypath+=("${path_pre_commit}")
            fi
        fi
        set -euo pipefail
    done

    # echo "Values arraypath "
    # for i in "${arraypath[@]}"; do
    #     echo "Valor: $i";
    # done
}

function precommit {
    if [ "$levellog" == "debug" ]; then echo "function precommit:"; fi

    #echo "$path"
    for i in "${arraypath[@]}"; do
        echo "pre-commit: $i";
        cd $path
        cd $i
        pre-commit run -a
    done
}

# Comenzar Acciones


get_commit
create_array_path
precommit
