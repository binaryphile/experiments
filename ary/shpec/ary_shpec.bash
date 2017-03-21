source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_source
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

shpec_source lib/ary.bash

describe Ary.map
  it "returns the array with no block"; (
    samples=( zero one )
    Ary.map samples
    assert equal 'declare -a __='\''([0]="zero" [1]="one")'\' "$(declare -p __)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns the array in a named variable with no block"
    samples=( zero one )
    Ary.map samples =results
    assert equal 'declare -a results='\''([0]="zero" [1]="one")'\' "$(declare -p results)"
  end

  it "errors if the return name doesn't start with ="
    stop_on_error off
    Ary.map samples results
    assert unequal 0 $?
    stop_on_error
  end

  it "returns the resulting default array with a block"; (
    samples=( zero one )
    Ary.map samples block {a,} 'echo "${a^^}"'
    assert equal 'declare -a __='\''([0]="ZERO" [1]="ONE")'\' "$(declare -p __)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns the resulting default array with a heredoc block"; (
    samples=( zero one )
    Ary.map samples block {a,} do <<'end'
      echo "${a^^}"
end
    assert equal 'declare -a __='\''([0]="ZERO" [1]="ONE")'\' "$(declare -p __)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe Ary.each
  it "does the block with a block"
    samples=( zero one )
    result=$(Ary.each samples block {a,} 'echo -n "${a^^} "')
    assert equal 'ZERO ONE ' "$result"
  end

  it "does the block with a heredoc block"; (
    samples=( zero one )
    result=$(Ary.each samples block {a,} do <<'end'
      echo -n "${a^^} "
end
    )
    assert equal 'ZERO ONE ' "$result"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
