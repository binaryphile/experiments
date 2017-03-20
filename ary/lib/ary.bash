Ary.map () {
  local -n __ary
  local __block=(block a 'echo "$a"' )
  local __item
  local __retval='=__'

  while [[ -n $1 ]]; do
    [[ $1 == 'block'      ]] && { __block=( "$@" ); shift $#; continue ;}
    [[ -z $__ary          ]] && { __ary=$1        ; shift   ; continue ;}
    [[ $__retval == '=__' ]] && { __retval=$1     ; shift   ; continue ;}
  done

  [[ $__retval == =* ]] || return
  __retval=${__retval:1}
  eval "$__retval=()"

  for __item in "${__ary[@]}"; do
    eval "$__retval+=( "$("${__block[@]}" "$__item")")"
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
