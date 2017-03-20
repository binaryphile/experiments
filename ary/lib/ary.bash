Ary.map () {
  local -n __ary
  local __block=( block a 'echo "$a"' )
  local __item
  local __retval

  while [[ -n $1 && $1 != 'block' ]]; do
    [[ -z $__ary    ]] && { __ary=$1    ; shift ; continue ;}
    [[ -z $__retval ]] && { __retval=$1 ; shift ;}
  done

  [[ -z $__retval     ]] && __retval='=__'
  [[ $__retval == =*  ]] || return
  __retval=${__retval:1}
  eval "$__retval"'=()'

  [[ $1 == 'block'  ]] && {
    __block=( "$@" )
    [[ ${__block[-1]} == 'do' ]] && __block=( "${__block[@]:0:$((${#__block[@]}-1))}" "$(</dev/stdin)" )
  }

  for __item in "${__ary[@]}"; do
    eval "$__retval"'+=( "$("${__block[@]}" "$__item")" )'
  done
}

block () {
  local __params=( "${@:1:$(( $#/2 ))}" )
  local __args=( "${@:$(( $#/2 + 2 ))}" )
  local __lambda=${@:$(( $#/2 + 1 )):1}
  local __i

  for (( __i = 0; __i < ${#__params[@]}; __i++ )); do
    local "${__params[__i]}=${__args[__i]}" || return
  done
  eval "$__lambda"
}
