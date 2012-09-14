# THIS FILE CONTAINS PORTIONS COPIED FROM:

#   bash_completion - programmable completion functions for bash 3.x
#   http://bash-completion.alioth.debian.org/
#   RELEASE: 20080617.5

if [[ $- == *v* ]]; then
	BASH_COMPLETION_ORIGINAL_V_VALUE="-v"
else
	BASH_COMPLETION_ORIGINAL_V_VALUE="+v"
fi

if [[ -n $BASH_COMPLETION_DEBUG ]]; then
	set -v
else
	set +v
fi

# Alter the following to reflect the location of this file.
#
[ -n "$BASH_COMPLETION" ] || BASH_COMPLETION=/etc/bash_completion
[ -n "$BASH_COMPLETION_DIR" ] || BASH_COMPLETION_DIR=/etc/bash_completion.d
readonly BASH_COMPLETION BASH_COMPLETION_DIR

# Set a couple of useful vars
#
UNAME=$( uname -s )
# strip OS type and version under Cygwin (e.g. CYGWIN_NT-5.1 => Cygwin)
UNAME=${UNAME/CYGWIN_*/Cygwin}
RELEASE=$( uname -r )

# features supported by bash 2.05 and higher
if [ ${BASH_VERSINFO[0]} -eq 2 ] && [[ ${BASH_VERSINFO[1]} > 04 ]] ||
   [ ${BASH_VERSINFO[0]} -gt 2 ]; then
	declare -r bash205=$BASH_VERSION 2>/dev/null || :
	default="-o default"
	dirnames="-o dirnames"
	filenames="-o filenames"
fi
# features supported by bash 2.05b and higher
if [ ${BASH_VERSINFO[0]} -eq 2 ] && [[ ${BASH_VERSINFO[1]} = "05b" ]] ||
   [ ${BASH_VERSINFO[0]} -gt 2 ]; then
	declare -r bash205b=$BASH_VERSION 2>/dev/null || :
	nospace="-o nospace"
fi
# features supported by bash 3.0 and higher
if [ ${BASH_VERSINFO[0]} -gt 2 ]; then
	declare -r bash3=$BASH_VERSION 2>/dev/null || :
	bashdefault="-o bashdefault"
	plusdirs="-o plusdirs"
fi
# start of section containing completion functions called by other functions

# This function checks whether we have a given program on the system.
# No need for bulky functions in memory if we don't.
#
have()
{
	unset -v have
	PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin type $1 &>/dev/null &&
		have="yes"
}

# use GNU sed if we have it, since its extensions are still used in our code
#
[ $UNAME != Linux ] && have gsed && alias sed=gsed

# This function checks whether a given readline variable
# is `on'.
#
_rl_enabled()
{
    [[ "$( bind -v )" = *$1+([[:space:]])on* ]]
}

# This function shell-quotes the argument
quote()
{
	echo \'${1//\'/\'\\\'\'}\' #'# Help vim syntax highlighting
}

# This function quotes the argument in a way so that readline dequoting 
# results in the original argument
quote_readline()
{
	local t="${1//\\/\\\\}"
	echo \'${t//\'/\'\\\'\'}\' #'# Help vim syntax highlighting
}

# This function shell-dequotes the argument
dequote()
{
	eval echo "$1"
}

# Get the word to complete
# This is nicer than ${COMP_WORDS[$COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# it will complete just "foo", not "foobar", which is what the user wants.)
#
#
# Accepts an optional parameter indicating which characters out of
# $COMP_WORDBREAKS should NOT be considered word breaks. This is useful
# for things like scp where we want to return host:path and not only path.
_get_cword()
{
	if [[ "${#COMP_WORDS[COMP_CWORD]}" -eq 0 ]] || [[ "$COMP_POINT" == "${#COMP_LINE}" ]]; then
		echo "${COMP_WORDS[COMP_CWORD]}"
	else
		local i
		local cur="$COMP_LINE"
		local index="$COMP_POINT"
		for (( i = 0; i <= COMP_CWORD; ++i )); do
			while [[ "${#cur}" -ge ${#COMP_WORDS[i]} ]] && [[ "${cur:0:${#COMP_WORDS[i]}}" != "${COMP_WORDS[i]}" ]]; do
				cur="${cur:1}"
				index="$(( index - 1 ))"
			done
			if [[ "$i" -lt "$COMP_CWORD" ]]; then
				local old_size="${#cur}"
				cur="${cur#${COMP_WORDS[i]}}"
				local new_size="${#cur}"
				index="$(( index - old_size + new_size ))"
			fi
		done
		
		if [[ "${COMP_WORDS[COMP_CWORD]:0:${#cur}}" != "$cur" ]]; then
			# We messed up! At least return the whole word so things 
			# keep working
			echo "${COMP_WORDS[COMP_CWORD]}"
		else
			echo "${cur:0:$index}"
		fi
	fi
}

# This function performs file and directory completion. It's better than
# simply using 'compgen -f', because it honours spaces in filenames.
# If passed -d, it completes only on directories. If passed anything else,
# it's assumed to be a file glob to complete on.
#
_filedir()
{
	local IFS=$'\t\n' xspec

	_expand || return 0

	local toks=( ) tmp
	while read -r tmp; do
		[[ -n $tmp ]] && toks[${#toks[@]}]=$tmp
	done < <( compgen -d -- "$(quote_readline "$cur")" )
	
	if [[ "$1" != -d ]]; then
		xspec=${1:+"!*.$1"}
		while read -r tmp; do
			[[ -n $tmp ]] && toks[${#toks[@]}]=$tmp
		done < <( compgen -f -X "$xspec" -- "$(quote_readline "$cur")" )
	fi

	COMPREPLY=( "${COMPREPLY[@]}" "${toks[@]}" )
}

# This function expands tildes in pathnames
#
_expand()
{
	# FIXME: Why was this here?
	#[ "$cur" != "${cur%\\}" ] && cur="$cur\\"

	# expand ~username type directory specifications
	if [[ "$cur" == \~*/* ]]; then
		eval cur=$cur
	elif [[ "$cur" == \~* ]]; then
		cur=${cur#\~}
		COMPREPLY=( $( compgen -P '~' -u $cur ) )
		return ${#COMPREPLY[@]}
	fi
}

_remove_comp_word()
{
	if [[ COMP_CWORD -eq 0 ]]; then
		return
	elif [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
		local old_cw0="${COMP_WORDS[0]}"
		local new_cw0="${COMP_WORDS[1]}"
		local old_length="${#COMP_LINE}"
		COMP_LINE=${COMP_LINE#${old_cw0}}
		local head=${COMP_LINE:0:${#new_cw0}}
		local i=1
		while [[ $head != $new_cw0 ]]; do
			COMP_LINE=${COMP_LINE:1}
			head=${COMP_LINE:0:${#new_cw0}}
			if (( ++i > 10 )); then
				break
			fi
		done
		local new_length="${#COMP_LINE}"
		COMP_POINT=$(( COMP_POINT + new_length - old_length ))
		
		COMP_CWORD=$(( COMP_CWORD - 1 ))
		for (( i=0; i < ${#COMP_WORDS[@]} - 1; ++i )); do
			COMP_WORDS[i]="${COMP_WORDS[i+1]}"
		done
		unset COMP_WORDS[${#COMP_WORDS[@]}-1]
	else
		return
	fi
}

# A meta-command completion function for commands like sudo(8), which need to
# first complete on a command, then complete according to that command's own
# completion definition - currently not quite foolproof (e.g. mount and umount
# don't work properly), but still quite useful.
#
_command()
{
	local cur func cline cspec noglob cmd done i \
	      _COMMAND_FUNC _COMMAND_FUNC_ARGS

	_remove_comp_word
	COMPREPLY=()
	cur=`_get_cword`
	# If the the first arguments following our meta-command-invoker are
	# switches, get rid of them. Most definitely not foolproof.
	done=
	while [ -z $done ] ; do
		cmd=${COMP_WORDS[0]}
		if [[ "$cmd" == -* ]] && [[ $COMP_CWORD -ge 1 ]]; then
	    	_remove_comp_word
	    elif [[ "$cmd" == -* ]] && [[ $COMP_CWORD -eq 0 ]]; then
	    	return
	    else
			done=1
	    fi
	done

	if [[ $COMP_CWORD -eq 0 ]]; then
		COMPREPLY=( $( compgen -c -- $cur ) )
	elif complete -p $cmd &>/dev/null; then
		cspec=$( complete -p $cmd )
		if [ "${cspec#* -F }" != "$cspec" ]; then
			# complete -F <function>
			#
			# COMP_CWORD and COMP_WORDS() are not read-only,
			# so we can set them before handing off to regular
			# completion routine

			# get function name
			func=${cspec#*-F }
			func=${func%% *}
			
			if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
				$func $cmd "${COMP_WORDS[${#COMP_WORDS[@]}-1]}"	"${COMP_WORDS[${#COMP_WORDS[@]}-2]}"
			else
				$func $cmd "${COMP_WORDS[${#COMP_WORDS[@]}-1]}"
			fi

			# remove any \: generated by a command that doesn't
			# default to filenames or dirnames (e.g. sudo chown)
			# FIXME: I'm pretty sure this does not work!
			if [ "${cspec#*-o }" != "$cspec" ]; then
				cspec=${cspec#*-o }
				cspec=${cspec%% *}
				if [[ "$cspec" != @(dir|file)names ]]; then
					COMPREPLY=("${COMPREPLY[@]//\\\\:/:}")
				fi
			fi
		elif [ -n "$cspec" ]; then
			cspec=${cspec#complete};
			cspec=${cspec%%$cmd};
			COMPREPLY=( $( eval compgen "$cspec" -- "$cur" ) );
		fi
	fi

	[ ${#COMPREPLY[@]} -eq 0 ] && _filedir
}
complete -F _command $filenames nohup exec nice eval strace time ltrace then \
	else do vsound command xargs tsocks

_root_command()
{
	PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin _command $1 $2 $3
}
complete -F _root_command $filenames sudo fakeroot really

# source completion directory definitions
if [ -d $BASH_COMPLETION_DIR -a -r $BASH_COMPLETION_DIR -a \
     -x $BASH_COMPLETION_DIR ]; then
	for i in $BASH_COMPLETION_DIR/*; do
		[[ ${i##*/} != @(*~|*.bak|*.swp|\#*\#|*.dpkg*|*.rpm@(orig|new|save)) ]] &&
			[ \( -f $i -o -h $i \) -a -r $i ] && . $i
	done
fi
unset i
