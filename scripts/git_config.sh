#!/bin/bash

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

. "${0%/*}/.helpers.sh"
function have_git_version () { version_ge "$git_version" "$1"; }

gc="git config --global"
config () {
  #echo "$@"
  $gc "$@"
}

# [settings]
# TODO: figure out $gc core.autocrlf        input

$gc color.ui             auto

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
parse_grep_colors

# make tabs whitespace errors
#$gc core.whitespace      "trailing-space,space-before-tab,tab-in-indent"

$gc merge.log            true

$gc instaweb.local       true
$gc instaweb.httpd       "/usr/sbin/apache2 -f"
$gc instaweb.port        4321
$gc instaweb.modulepath  /usr/lib/apache2/modules

$gc sendemail.confirm    always
$gc sendemail.multiedit  true

$gc web.browser          firefox

if have_git_version 1.7.5; then
  $gc push.default         upstream
else
  # deprecated synonym
  $gc push.default         tracking
fi

# https://github.com/git/git/tree/master/contrib/diff-highlight
# NOTE: this might need --color
# for cmd in log show diff; { $gc pager.$cmd "diff-highlight | $PAGER"; }

# [diff helpers]
# use with ".gitattributes": '*.png diff=exif'

$gc diff.exif.textconv    'exiftool'; # exiv2 ?
$gc diff.strings.textconv 'strings'
$gc diff.ziplist.textconv 'unzip -l'
$gc diff.pdftext.textconv 'pdftotext'

# [aliases]
# NOTE: git uses 'sh'
# find some nice examples at: https://git.wiki.kernel.org/index.php/Aliases

$gc alias.exec            $'!_() { exec "$@"; }; _'

$gc alias.add-p           $'add -p'
$gc alias.adp             $'add -p'
$gc alias.touch           $'add -N'

$gc alias.b               $'branch'
$gc alias.bv              $'branch  -vv'
$gc alias.bav             $'branch -avv'
$gc alias.bnm             $'branch --no-merged'

# consider -C -C -C30
$gc alias.blamehard       $'blame -w -C -C -C'

#$gc alias.bunch           $'!env FILE_LOG_LEVEL=off gitbunch'
#$gc alias.bunch           $'!gitbunch'

$gc alias.civ             $'commit -v'
$gc alias.amend           $'commit -v --amend'

$gc alias.co              $'checkout'
$gc alias.cob             $'checkout -b'
$gc alias.com             $'checkout master'
$gc alias.cobt            $'!_() { git branch-track "$@"; git co "$1"; }; _'

$gc alias.cpan-mailmap    $'!echo "`git config user.name` <`awk \047/^user / { print tolower($2) }\047 ~/.pause`@cpan.org> <`git config user.email`>"'

# clone repo, make remote "origin" for first arg and "upstream" for second
$gc alias.clone-fork      $'!_() { fork=$1 upstream=$2; forkdir=${3:-${fork##*/}}; forkdir=${forkdir%.git}; git clone $fork; cd ${forkdir}; git remote add upstream $upstream; }; _'

# git rev-parse --default master --symbolic-full-name HEAD
$gc alias.current-branch  $'!git symbolic-ref HEAD | sed s-^refs/heads/--'

# diff diff diff
$gc alias.vimdiff         $'!vim +Gdiff'

git_ix='diff --cached -M --minimal'
$gc alias.ix               "$git_ix"

$gc alias.diffstat        $'diff --stat -r'
$gc alias.diffst          $'diff --stat -r'

# show char-by-char (or word-by-word) differences instead of whole lines
function alias_diffs () {
  alias="$1" prefix="$2" suffix="$3"
  $gc "alias.ix$alias"     "$prefix${prefix:+ }${git_ix} ${suffix}"
  $gc "alias.diff$alias"   "$prefix${prefix:+ }diff $suffix"
  $gc "alias.logp$alias"   "$prefix${prefix:+ }log -p $suffix"
}

alias_diffs cw            '' $'--color-words=.'
alias_diffs cww           '' $'--color-words=\\\\w+'
alias_diffs hl            '!_() { git ' ' --color "$@" | diff-highlight | $PAGER; }; _'

$gc alias.diffwithsubs    $'!git submodule summary; git diff'

# the sha1 for an empty tree in case you want to compare something to a bare repo
$gc alias.empty-tree-sha1 $'hash-object -t tree /dev/null'

#$gc alias.change-github-username $'!sed -i -re \047s/(github.com:)magnificent-tears/\\1rwstauner/\047 .git/config'

# Create a script that can be verified and then piped to sh.
# TODO: split args b/t log and fp with `--`.
$gc alias.format-patch-script  $'!_() { file="$1"; shift; git log --oneline "$file" | perl -e \'print reverse <STDIN>\' | perl -lne \'BEGIN { @opts = splice @ARGV } ($c, $s) = split / /, $_, 2; print q[git format-patch -n --start-number ], ++$patch, qq[ @opts -1 $c # $s]\' -- "$@"; }; _'

# filenames at the top: --heading --break ?
$gc alias.grep-todo       $'grep -iE "to.?do|fix.?me"'

$gc alias.homepage-metacpan      $'!curl -v -d "login=`git config github.user`&token=`git config github.token`&values[homepage]=http://metacpan.org/release/${PWD##*/}" "https://github.com/api/v2/json/repos/show/rwstauner/${PWD##*/}"'

# uses patchutils/interdiff to see upstream modifications b/t two commits (origin/master and local branch)
$gc alias.intercommit     $'!_() { git show "$1" > .git/commit1 && git show "$2" > .git/commit2 && interdiff .git/commit[12] | less -FRS; }; _'

$gc alias.initial-commit  $'!git rev-list --all | tail -n 1'

# gitk
$gc alias.k               $'!gitk'
# Gitv (from the command line seems to require an argument)
$gc alias.kv              $'!vim -c "silent Gitv" `if test "$#" -gt 0; then echo "$@"; else echo .; fi`'

# there must be a better way
$gc alias.last-sha        $'!git show HEAD --oneline | head -n1 | awk \047{print $1}\047'
$gc alias.last-tag        $'!git describe --tags --long | sed -re \047s/-[0-9]+-g[a-f0-9]+$//\047'

$gc alias.log1            $'log --oneline'

$gc alias.logdiff         $'log -p --full-diff'

# show new commits after last fetch
$gc alias.lc              $'log ORIG_HEAD.. --stat --no-merges'
$gc alias.log-fetched     $'log ..FETCH_HEAD --stat --no-merges'
# this should probably be log-remote and figure out the tracking remote
$gc alias.log-origin      $'log ..origin --stat --no-merges'

# The --stat-name-width=${COLUMNS:-80} arg doesn't seem to help very much.
$gc alias.logstat         $'log --stat'
$gc alias.logst           $'log --stat --no-merges'

$gc alias.log-since-tag   $'!_() { tag=`git last-tag`; revs=$tag..HEAD; git log $* $revs; echo "\n=== $revs ===\n"; git tag-summary $tag; }; _'

# rjbs!
$gc alias.hist            $'log --graph --all --color=always --decorate'

# condense log output (modified from http://coderwall.com/p/euwpig)
$gc alias.lg               "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%aN%Creset %C(blue)<%aE>%Creset' --abbrev-commit"
$gc alias.lgpcw           $'!git lg -p --color-words=.'

# ls-files doesn't tab-complete, so just shorten it
$gc alias.ls              $'!_() { git ls-files "$@" | $PAGER; }; _'
$gc alias.lsgrep          $'!_() { git ls-files | grep --color=always "$@" | $PAGER; }; _'

$gc alias.merge-delete    $'!_() { git merge "$1" && git branch -d "$1"; }; _'

# provide rebasing music (https://coderwall.com/p/at9bya)
#$gc alias.mav             $'!afplay ~/Music/Danger\\ Zone.mp3 & LASTPID=$! \ngit rebase -i $1 \nkill -9 $LASTPID\n true'

# https://blog.afoolishmanifesto.com/posts/git-aliases-for-your-life/
# git rebase --root --onto origin/master -i --autosquash
# gitk $(cat .git/MERGE_HEAD) $(cat .git/ORIG_HEAD) "$@" &
# gitk ^origin/master HEAD

# what new commits have been created by the last command (like "git pull")
$gc alias.new             $'!_() { git log $1@{1}..$1@{0} "$@"; }; _'

$gc alias.prune-all       $'!git remote | xargs -n 1 git remote prune'

$gc alias.pulls           $'!git pull; test -f ${GIT_DIR:-.}/.gitmodules && git submodule update'

# pum doesn't seem to be storing the fetch, so do both
$gc alias.pum             $'!git fetch upstream; git pull upstream master'

$gc alias.pusht           $'!_() { git push "$@"; git push --tags "$@"; }; _'

$gc alias.branch-to-remote       $'!_() { branch=${1:-`git current-branch`} remote=${2:-origin}; git config branch.$branch.remote $remote; git config branch.$branch.merge refs/heads/$branch; }; _'
$gc alias.branch-track    $'!_() { branch=${1} remote=${2:-origin}; git branch --track $branch remotes/$remote/$branch; }; _'

# load pull requests as remote branches (github++)
# https://gist.github.com/piscisaureus/3342247
$gc alias.fetch-pr        $'!_() { remote="${1:-origin}"; git fetch "$remote" "+refs/pull/*/head:refs/remotes/$remote/pr/*"; }; _'
$gc alias.branch-pr       $'!_() { branch="$1"; pr="$2"; remote="${3:-origin}"; git co -b "$branch" -t "refs/remotes/$remote/pr/$pr"; }; _'

# Since git operates from the project root dir `pwd` also works.
#$gc alias.root            $'!pwd'
$gc alias.root            $'rev-parse --show-toplevel'

# run daemon (use !git to run from repo root) then try git ls-remote
$gc alias.serve           $'!git daemon --reuseaddr --verbose  --base-path=. --export-all ./.git'

$gc alias.st              $'!_() { if [ $# -gt 0 ]; then git status "$@"; else git status && git stash list | sed -re "s/^([^:]+):/\\\033[33m\\1\\\033[00m:/"; fi; }; _'
$gc alias.s               $'status -s -b -u'
$gc alias.tag-summary     $'!_() { git show --summary ${1:-`git last-tag`}; }; _'

  $gc alias.would-update  "!_() { branch=\$(git symbolic-ref HEAD | sed s-^refs/heads/--); range=\"\${1:-..\`git config branch.\$branch.remote\`}/\$branch\"; { git log --color --graph --oneline \"\$range\"; git diff --color --stat \"\$range\"; git submodule-would-update; } | \${GIT_PAGER:-\${PAGER:-less -FRX}}; }; _"

# Version 1.6 doesn't have git diff --submodule.
# Using git log lets us pass more options.
  $gc alias.submodule-would-update-simple "!_() { range=\"\${1:-..\`git remote\`}\"; git submodule -q foreach 'echo \$path' | while read path; do git diff --submodule=log \"\$range\" \$path; done; }; _"
  $gc alias.submodule-would-update-fancy  "!_() { range=\"\${1:-..\`git remote\`}\"; git submodule -q foreach 'echo \$path' | while read path; do submod_range=\`git diff \$range \$path | perl -le ' while(<>){ if( /^[-+]Subproject commit (\\S+)/ ){ push @c, \$1 } } print join q[..], @c'\`; (test -n \"\$submod_range\" && cd \$path && echo Submodule \$path \$submod_range && git log --color --exit-code --graph --oneline \"\$@\" \$submod_range); done | LESS= /usr/bin/less -FRX; }; _"

# We could do if have_git_version 1.7.0 to use 'git diff --submodule' but I
# prefer the other options that I can pass to log.
  $gc alias.submodule-would-update "!git submodule-would-update-fancy"


# whois takes a name or email
$gc alias.whois           $'!_() { git log -i -1 --pretty="format:%an <%ae>\n" --author="$1"; }; _'
# whatis takes a commit name
$gc alias.whatis          $'show -s --pretty="tformat:%h (%s, %ad)" --date=short'

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
