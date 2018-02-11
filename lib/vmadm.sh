vmadm() {
	case "${1}" in
		create)
			local templateFile="var/templates/${2}.json"
			local tempFile=$(mktemp --suffix=radm)

			# Verify template json file exists
			if [[ ! -f ${templateFile} ]]; then
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
			render ${templateFile} > ${tempFile}
			if (( $(grep -c '""' ${tempFile}) > 0 )); then
				err "Not all variables are replaced"
				# TODO: list existing or not used variables
				return 2
			fi

			# Return commands
			echo "'cat > template.json' < ${tempFile}"
			echo "vmadm create -f template.json"
			;;
		*)
			echo ${@}
		;;
	esac
}
