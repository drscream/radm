vmadm() {
	case "${1}" in
		create)
			local templateFile="var/templates/${2}"
			local tempFile=$(mktemp)

			# Verify template json file exists
			if [[ ! -f ${templateFile}.json ]]; then
				err "Template does not exists"
				return 1
			fi

			# Define variables based on each parameter
			for entry in ${@}; do
				if [[ ${entry} = --* ]]; then
					# Remove --
					local entry=${entry##--}
					# Split by equal
					local variable=${entry%=*}
					local value=${entry##*=}
					# Defaults for DNS_DOMAIN
					DNS_DOMAIN=${FQDN#*.}
					# Provide VARIABLES
					eval "${variable^^}=${value}"
					# Network special for ips and gateways
					case ${variable} in
						ips)
							local ips+=("${value}")
						;;
						gateways)
							local gateways+=("${value}")
						;;
					esac
					# Overwrite IPS and GATEWAYS
					local tmpIps=$(printf ",\"%s\"" "${ips[@]}")
					local tmpGateways=$(printf ",\"%s\"" "${gateways[@]}")
					local IPS=${tmpIps:1}
					local GATEWAYS=${tmpGateways:1}
				fi
			done

			# Render existing template
			render ${templateFile}.json > ${tempFile}
			if (( $(grep -c '""' ${tempFile}) > 0 )); then
				err "Not all variables are replaced: "
				sed -n 's:.*\${\(.*\)}.*:\1, :p' ${templateFile}.json | tr '[:upper:]' '[:lower:]'
				return 2
			fi

			# Return commands
			echo "ssh imgadm import ${UUID}"
			echo "scp ${tempFile} /tmp/template.json"
			echo "ssh vmadm create -f /tmp/template.json"
			# Allow additional scripts to be executed
			if [[ -f ${templateFile}.sh ]]; then
				echo "local ${templateFile}.sh ${@}"
			fi
			;;
		*)
			echo ${@}
		;;
	esac
}
