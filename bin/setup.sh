function _ocd() {
	local nanoseconds=$(date +%s%N)
	local commands_file="/tmp/ocd-${nanoseconds}"

	command "$OCD_PATH/bin/ocd.rb" "$commands_file"

	if [[ -f $commands_file ]]; then
		source $commands_file
		command rm -f $commands_file
	else
		echo "$commands_file not found."
	fi
}

function ocd() {
	_ocd
}
