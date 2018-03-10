# Script provide utils functions which may used by radm
# vim:ft=sh

render() {
	local inFile="${1}"

	while read -r line ; do
		while [[ "${line}" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
			LHS=${BASH_REMATCH[1]}
			RHS="$(eval echo "\"${LHS}\"")"
			line=${line//$LHS/$RHS}
		done
		echo -e "${line}"
	done < ${inFile}
}

err() {
	local msg=${@}
	echo Error: ${msg}
}

usage() {
	echo "${0} [hypervisor] [vmadm|imgadm] [create] [template] [options]"
	echo
	exit 1
}
