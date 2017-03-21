Ary.each () {
  local -n __ary=$1; shift
  local __block=( block {a,} 'echo -n "$a"' )
  local __item

  [[ $1 == 'block'  ]] && {
    case ${@: -1} in
      'do'  ) __block=( "${@:1:$(($#-1))}" "$(</dev/stdin)" );;
      *     ) __block=( "$@"                                );;
    esac
  }

  for __item in "${__ary[@]}"; do
    "${__block[@]}" "$__item"
  done
}

Ary.map () {
  local -n __ary=$1; shift
  local __block=( block {a,} 'echo -n "$a"' )
  local __item
  local __retval

  [[ -n $1 && $1 != 'block' ]] && { __retval=$1; shift ;}

  [[ -z $__retval     ]] && __retval='=__'
  [[ $__retval == =*  ]] || return
  __retval=${__retval:1}
  eval "$__retval"'=()'

  [[ $1 == 'block'  ]] && {
    case ${@: -1} in
      'do'  ) __block=( "${@:1:$(($#-1))}" "$(</dev/stdin)" );;
      *     ) __block=( "$@"                                );;
    esac
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
