#!/bin/bash
# vim: set fdm=marker:

# Turn off xtrace that helpers turns on (too much noise for this).
. "${0%/*}/.helpers.sh" +x

file="$HOME/.gitconfig"
umask 0077
touch "$file"
chmod 0600 "$file"

# if there's no modeline put one there
if test -f "$file" && ! grep -qE '^# vim: .+:$' "$file"; then
  # set ro to remind me not to edit the file
  sed -i -e '1 i# vim: set ro ts=2:' "$file"
fi

git_version=`git --version`

# helper functions {{{

have_git_version () {
  version_ge "$git_version" "$1";
}

config () {
  git config --global "$@"
}

alias () {
  local name="$1" cmd="$2"
  # If it's an external command that uses any argument vars wrap it in a function.
  [[ "${cmd:0:1}" == "!" ]] && [[ "$cmd" =~ \$\{?[1-9@*] ]] && cmd="!_() { ${2#!}; }; _"
  config alias."$name" "$cmd"
}

grep_color () {
  local slot="$1" sgr="$2" val=""
  for attr in ${sgr//;/ }; do
    case "$attr" in
      01) val="bold $val";;
      31) val="$val red";;
      32) val="$val green";;
      33) val="$val yellow";;
      34) val="$val blue";;
      35) val="$val magenta";;
      36) val="$val cyan";;
      37) val="$val white";;
    esac
  done
  config color.grep."$slot" "${val# }"
}

parse_grep_colors () {
  # ms=01;31:mc=01;33:sl=:cx=34:fn=35:ln=32:bn=32:se=36
  local slot color
  for slot in ${GREP_COLORS//:/ }; do
    color="${slot#*=}"
    case "${slot%=*}" in
      mt)
          grep_color matching   $color
          grep_color context    $color
        ;;
      ms) grep_color matching   $color;;
      mc) grep_color context    $color;;
      sl)  ;;
      cx)  ;;
      fn) grep_color filename   $color;;
      ln) grep_color linenumber $color;;
      bn)  ;;
      se) grep_color separator  $color;;
    esac
  done
}

# }}}

parse_grep_colors

# [settings]
# TODO: figure out config core.autocrlf        input

config color.ui          auto

config core.excludesFile ~/.excludes

config rebase.autosquash true

config grep.lineNumber   true

# make tabs whitespace errors
#config core.whitespace      "trailing-space,space-before-tab,tab-in-indent"

config merge.log            true

config instaweb.local       true
config instaweb.httpd       "/usr/sbin/apache2 -f"
config instaweb.port        4321
config instaweb.modulepath  /usr/lib/apache2/modules

config sendemail.confirm    always
config sendemail.multiedit  true

config web.browser          firefox

if have_git_version 1.7.5; then
  config push.default         upstream
else
  # deprecated synonym
  config push.default         tracking
fi

# https://github.com/git/git/tree/master/contrib/diff-highlight
# NOTE: this might need --color
# for cmd in log show diff; { config pager.$cmd "diff-highlight | $PAGER"; }

# [diff helpers]
# use with ".gitattributes": '*.png diff=exif'

config diff.exif.textconv    'exiftool'; # exiv2 ?
config diff.strings.textconv 'strings'
config diff.ziplist.textconv 'unzip -l'
config diff.pdftext.textconv 'pdftotext'

# [aliases]
# NOTE: git uses 'sh'
# find some nice examples at: https://git.wiki.kernel.org/index.php/Aliases

# Execute a command from git root with git env.
# Use function so that we get to sh's builtin.
alias exec '!exec "$@"'

alias add-p           'add -p'
alias adp             'add -p'
alias touch           'add -N'

alias b               'branch'
alias bv              'branch  -vv'
alias bav             'branch -avv'
alias bnm             'branch --no-merged'

# consider -C -C -C30
alias blamehard       'blame -w -C -C -C'

#alias bunch           '!env FILE_LOG_LEVEL=off gitbunch'
#alias bunch           '!gitbunch'

alias civ             'commit -v'
alias amend           'commit -v -n --amend'

alias co              'checkout'
alias cob             'checkout -b'
alias com             'checkout master'

alias commit-vars     '!n="${1:-`git config user.name`}"; e="${2:-`git config user.email`}"; echo GIT_COMMITTER_NAME=\"$n\" GIT_COMMITTER_EMAIL=\"$e\" GIT_AUTHOR_NAME=\"$n\" GIT_AUTHOR_EMAIL=\"$e\"'

alias cobt            '!git branch-track "$@"; git co "$1"'

# TODO: heredoc?
alias cpan-mailmap    $'!echo "`git config user.name` <`awk \047/^user / { print tolower($2) }\047 ~/.pause`@cpan.org> <`git config user.email`>"'

# clone repo, make remote "origin" for first arg and "upstream" for second
alias clone-fork      '!fork=$1 upstream=$2; forkdir=${3:-${fork##*/}}; forkdir=${forkdir%.git}; git clone $fork; cd ${forkdir}; git remote add upstream $upstream'

# git rev-parse --default master --symbolic-full-name HEAD
alias current-branch  '!git symbolic-ref HEAD | sed s-^refs/heads/--'

# diff diff diff
alias vimdiff    '!vim +Gdiff'

git_ix='diff --cached -M --minimal'
alias ix         "$git_ix"

alias diffstat   'diff --stat -r'
alias diffst     'diff --stat -r'

# show char-by-char (or word-by-word) differences instead of whole lines
alias_diffs () {
  alias="$1" prefix="$2" suffix="$3"
  config "alias.ix$alias"     "$prefix${prefix:+ }${git_ix} ${suffix}"
  config "alias.diff$alias"   "$prefix${prefix:+ }diff $suffix"
  config "alias.logp$alias"   "$prefix${prefix:+ }log -p $suffix"
  config "alias.showp$alias"  "$prefix${prefix:+ }show -p $suffix"
}

alias_diffs cw            '' $'--color-words=.'
alias_diffs cww           '' $'--color-words=\\\\w+'
alias_diffs hl            '!_() { git ' ' --color "$@" | diff-highlight | $PAGER; }; _'

alias diffwithsubs     '!git submodule summary; git diff'

# the sha1 for an empty tree in case you want to compare something to a bare repo
alias empty-tree-sha1  'hash-object -t tree /dev/null'

#alias change-github-username $'!sed -i -re \047s/(github.com:)magnificent-tears/\\1rwstauner/\047 .git/config'

# Create a script that can be verified and then piped to sh.
# TODO: split args b/t log and fp with `--`.
alias format-patch-script  $'!file="$1"; shift; git log --oneline "$file" | perl -e \'print reverse <STDIN>\' | perl -lne \'BEGIN { @opts = splice @ARGV } ($c, $s) = split / /, $_, 2; print q[git format-patch -n --start-number ], ++$patch, qq[ @opts -1 $c # $s]\' -- "$@"'

# filenames at the top: --heading --break ?
alias grep-todo       'grep -iE "to.?do|fix.?me"'

alias homepage-metacpan    '!curl -v -d "login=`git config github.user`&token=`git config github.token`&values[homepage]=http://metacpan.org/release/${PWD##*/}" "https://github.com/api/v2/json/repos/show/rwstauner/${PWD##*/}"'

# uses patchutils/interdiff to see upstream modifications b/t two commits (origin/master and local branch)
alias intercommit     '!git show "$1" > .git/commit1 && git show "$2" > .git/commit2 && interdiff .git/commit[12] | less -FRS'

alias initial-commit  '!git rev-list --all | tail -n 1'

alias k                '!gitk'
# Gitv (from the command line seems to require an argument)
alias kv               '!vim -c "silent Gitv" `if test "$#" -gt 0; then echo "$@"; else echo .; fi`'

# there must be a better way
alias last-sha        $'!git show HEAD --oneline | head -n1 | awk \047{print $1}\047'
alias last-tag        $'!git describe --tags --long | sed -re \047s/-[0-9]+-g[a-f0-9]+$//\047'

alias log1       'log --oneline'
alias logp       'log -p'

alias logdiff    'log -p --full-diff'

# The --stat-name-width=${COLUMNS:-80} arg doesn't seem to help very much.
logst='log --stat --no-merges'
alias logstat         'log --stat'
alias logst           "$logst"

# show new commits after last fetch
alias lc              "$logst ORIG_HEAD.."
alias log-fetched     "$logst ..FETCH_HEAD"
# this should probably be log-remote and figure out the tracking remote
alias log-origin      "$logst ..origin"

alias log-since-tag   $'!tag=`git last-tag`; revs=$tag..HEAD; git log "$@" $revs; echo "\n=== $revs ===\n"; git tag-summary $tag'

# rjbs!
alias hist             'log --graph --all --color=always --decorate'

# condense log output (modified from http://coderwall.com/p/euwpig)
alias lg               "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%aN%Creset %C(blue)<%aE>%Creset' --abbrev-commit"
alias lgpcw            '!git lg -p --color-words=.'

# ls-files doesn't tab-complete, so shorten it, and force it through a pager.
alias ls               '-p ls-files'
alias lsgrep           '!git ls-files | grep --color=always "$@" | $PAGER'

alias merge-delete     '!git merge "$1" && git branch -d "$1"'

# provide rebasing music (https://coderwall.com/p/at9bya)
#alias mav             $'!afplay ~/Music/Danger\\ Zone.mp3 & LASTPID=$! \ngit rebase -i $1 \nkill -9 $LASTPID\n true'

# https://blog.afoolishmanifesto.com/posts/git-aliases-for-your-life/
# git rebase --root --onto origin/master -i --autosquash
# gitk $(cat .git/MERGE_HEAD) $(cat .git/ORIG_HEAD) "$@" &
# gitk ^origin/master HEAD

# what new commits have been created by the last command (like "git pull")
alias new              '!git log $1@{1}..$1@{0} "$@"'

alias prune-all        '!git remote | xargs -n 1 git remote prune'

alias pulls            '!git pull; test -f ${GIT_DIR:-.}/.gitmodules && git submodule update'

# pum doesn't seem to be storing the fetch, so do both
alias pum              '!git fetch upstream; git pull upstream master'

alias pusht            '!git push "$@"; git push --tags "$@"'
alias pushup           '!git push -u "${1:-origin}" "${2:-`git current-branch`}"'

alias branch-to-remote  '!branch=${1:-`git current-branch`} remote=${2:-origin}; git config branch.$branch.remote $remote; git config branch.$branch.merge refs/heads/$branch'
alias branch-track      '!branch=${1} remote=${2:-origin}; git branch --track $branch remotes/$remote/$branch'

# load pull requests as remote branches (github++)
# https://gist.github.com/piscisaureus/3342247
alias fetch-pr         '!remote="${1:-origin}"; git fetch "$remote" "+refs/pull/*/head:refs/remotes/$remote/pr/*"'
alias branch-pr        '!branch="$1"; pr="$2"; remote="${3:-origin}"; git co -b "$branch" -t "refs/remotes/$remote/pr/$pr"'

# Since git operates from the project root dir `pwd` also works.
#$gc alias.root            $'!pwd'
alias root             'rev-parse --show-toplevel'

# run daemon (use !git to run from repo root) then try git ls-remote
alias serve            '!git daemon --reuseaddr --verbose  --base-path=. --export-all ./.git'

alias st              $'!if [ $# -gt 0 ]; then git status "$@"; else git status && git stash list | sed -re "s/^([^:]+):/\\\033[33m\\1\\\033[00m:/"; fi'

# Use $PAGER and -p to force (only for this command) sending color to pipe.
alias stpp             '!PAGER=fppt git -p st'

alias s                'status -s -b -u'
alias tag-summary      '!git show --summary ${1:-`git last-tag`}'

  alias would-update  "!branch=\$(git symbolic-ref HEAD | sed s-^refs/heads/--); range=\"\${1:-..\`git config branch.\$branch.remote\`}/\$branch\"; { git log --color --graph --oneline \"\$range\"; git diff --color --stat \"\$range\"; git submodule-would-update; } | \${GIT_PAGER:-\${PAGER:-less -FRX}}"

# Version 1.6 doesn't have git diff --submodule.
# Using git log lets us pass more options.
  # TODO: heredocs?
  alias submodule-would-update-simple "!range=\"\${1:-..\`git remote\`}\"; git submodule -q foreach 'echo \$path' | while read path; do git diff --submodule=log \"\$range\" \$path; done"
  alias submodule-would-update-fancy  "!range=\"\${1:-..\`git remote\`}\"; git submodule -q foreach 'echo \$path' | while read path; do submod_range=\`git diff \$range \$path | perl -le ' while(<>){ if( /^[-+]Subproject commit (\\S+)/ ){ push @c, \$1 } } print join q[..], @c'\`; (test -n \"\$submod_range\" && cd \$path && echo Submodule \$path \$submod_range && git log --color --exit-code --graph --oneline \"\$@\" \$submod_range); done | LESS= /usr/bin/less -FRX"

# We could do if have_git_version 1.7.0 to use 'git diff --submodule' but I
# prefer the other options that I can pass to log.
  alias submodule-would-update "!git submodule-would-update-fancy"


# whois takes a name or email
alias whois           $'log -i -1 --pretty="format:%an <%ae>\n" --author' # ="$1"'
# whatis takes a commit name
alias whatis           'show -s --pretty="tformat:%h (%s, %ad)" --date=short'

# https://coderwall.com/p/wazznq
# Undelete files from a COMMIT_HASH:
# git show --name-status COMMIT_HASH | grep -P "^D\t" | sed "s/D\t//" | xargs -n 1 git checkout COMMIT_HASH~1

# NOTE: things to add locally:
#
# [user] name, email
# [url work] insteadOf
# [url private] insteadOf
# [github] user, token
# [url github] insteadOf

lgc="$HOME/.gitconfig.local.sh"
if [[ -f "$lgc" ]]; then
  "$lgc"
else
  echo "No '$lgc' script found" 1>&2
fi

chmod 0600 "$file"
