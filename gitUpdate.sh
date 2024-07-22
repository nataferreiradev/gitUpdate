#!/bin/bash

path=$(pwd)
repos=("$path"/*/)

error_msg(){
    printf " \e[31m[✗]\e[0m \e[1m Falha para o diretório: $1\e[0m\n"
}

sucess_msg(){
    printf " \e[32m[✓]\e[0m \e[1m Concluído para o diretório: $1\e[0m\n"
}

isVerbose(){
    [[ -n "$v" ]]
}

v=""

check_uncommitted_changes(){
    if [[ -n $(git status -s) ]]; then
        return 0  # Há alterações não comitadas
    else
        return 1  # Não há alterações não comitadas
    fi
}


while getopts "v" opt
do
   case "$opt" in
      v ) v=1 ;;
   esac
done

for repo in "${repos[@]}"; do
    if [ -d "$repo" ]; then
        cd "$repo" || continue
        repo=$(basename "$repo")

        if [ ! -d .git ]; then
            if isVerbose; then
                error_msg "$repo (não é um repositório Git)"
            fi
            continue
        fi

        if check_uncommitted_changes; then
            error_msg "$repo há alterações não comitadas"
            continue
        fi

        if git show-ref --quiet refs/heads/main; then
            if git switch -q main && git pull -q; then
                sucess_msg "$repo"
                continue
            fi
            error_msg "$repo[main]"
        fi

        if git show-ref --quiet refs/heads/master; then
            if git switch -q master && git pull -q; then
                sucess_msg "$repo"
                continue
            fi
            error_msg "$repo[master]"
        fi

        if isVerbose; then
            error_msg "$repo (branches main e master não encontradas ou falha ao atualizar)"
        fi
    fi
done

