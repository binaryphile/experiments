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
  local -n __vals=$1; shift
  local __block=( block {a,} 'echo -n "$a"' )
  local __retvals
  local __retvar
  local __val

  [[ $1 == =*     ]] && { __retvar=$1; shift ;}
  [[ -z $__retvar ]] && __retvar='=__'
  __retvar=${__retvar:1}
  eval "$__retvar"'=()'

  case ${@: -1} in
    'do'  ) __block=( "${@:1:$(($#-1))}" "$(</dev/stdin)" );;
    *     ) __block=( "${@:1:$(($#-3))}" "${@: -2:1}"     );;
  esac

  for __val in "${__vals[@]}"; do
    block "${__block[@]}" "$__val"
    __retvals+=( "$__" )
  done
  eval "$__retvar"'=( "${__retvals[@]}" )'
}

block () {
  local __params=( "${@:1:$(( $#/2 ))}" )
  local __args=( "${@:$(( $#/2 + 2 ))}" )
  local __lambda=${@:$(( $#/2 + 1 )):1}
  local __i

  for (( __i = 0; __i < ${#__params[@]}; __i++ )); do
    local "${__params[__i]}=${__args[__i]}" || return
  done
  [[ $__lambda == *__=* ]] && { eval "$__lambda"; return ;}
  __=$(eval "$__lambda")
}
