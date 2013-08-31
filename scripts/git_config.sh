#!/bin/bash

file="$HOME/.gitconfig"
umask 0077
touch "$file"
chmod 0600 "$file"

# if there's no modeline put one there
if ! grep -qE '^# vim: .+:$' "$file"; then
  # set ro to remind me not to edit the file
  sed -i -e '1 i# vim: set ro ts=2:' "$file"
fi

git_version=`git --version`

. "${0%/*}/.helpers.sh"
function have_git_version () { version_ge "$git_version" "$1"; }

gc="git config --global"

# [settings]
# TODO: figure out $gc core.autocrlf        input

$gc color.ui             auto

# make tabs whitespace errors
$gc core.whitespace      "trailing-space,space-before-tab,tab-in-indent"

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

$gc alias.add-p           $'add -p'
$gc alias.adp             $'add -p'
$gc alias.touch           $'add -N'

$gc alias.b               $'branch'
$gc alias.bav             $'branch -av'
$gc alias.bnm             $'branch --no-merged'

#$gc alias.bunch           $'!env FILE_LOG_LEVEL=off gitbunch'
#$gc alias.bunch           $'!gitbunch'

$gc alias.civ             $'commit -v'
$gc alias.amend           $'commit -v --amend'

$gc alias.co              $'checkout'
$gc alias.cob             $'checkout -b'
$gc alias.com             $'checkout master'

$gc alias.cpan-mailmap    $'!echo "`git config user.name` <`awk \047/^user / { print tolower($2) }\047 ~/.pause`@cpan.org> <`git config user.email`>"'

# clone repo, make remote "origin" for first arg and "upstream" for second
$gc alias.clone-fork      $'!_() { fork=$1 upstream=$2; forkdir=${3:-${fork##*/}}; forkdir=${forkdir%.git}; git clone $fork; cd ${forkdir}; git remote add upstream $upstream; }; _'
$gc alias.current-branch  $'!git branch | awk \047/^[*] / { print $2 }\047'

# diff diff diff
$gc alias.vimdiff         $'!vim +Gdiff'
$gc alias.ix              $'diff --cached'

$gc alias.diffstat        $'diff --stat -r'
$gc alias.diffst          $'diff --stat -r'

# show char-by-char (or word-by-word) differences instead of whole lines
function alias_diffs () {
  alias="$1" prefix="$2" suffix="$3"
  $gc "alias.ix$alias"     "$prefix${prefix:+ }diff --cached $suffix"
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

# filenames at the top: --heading --break ?
$gc alias.grep-todo       $'grep -iE "to.?do|fix.?me"'

$gc alias.homepage-metacpan      $'!curl -v -d "login=`git config github.user`&token=`git config github.token`&values[homepage]=http://metacpan.org/release/${PWD##*/}" "https://github.com/api/v2/json/repos/show/rwstauner/${PWD##*/}"'

# uses patchutils/interdiff to see upstream modifications b/t two commits (origin/master and local branch)
$gc alias.intercommit     $'!_() { git show "$1" > .git/commit1 && git show "$2" > .git/commit2 && interdiff .git/commit[12] | less -FRS; }; _'

# gitk
$gc alias.k               $'!gitk'
# Gitv (from the command line seems to require an argument)
$gc alias.kv              $'!vim -c "silent Gitv" `if test "$#" -gt 0; then echo "$@"; else echo .; fi`'

# there must be a better way
$gc alias.last-sha        $'!git show HEAD --oneline | head -n1 | awk \047{print $1}\047'
$gc alias.last-tag        $'!git describe --tags --long | sed -re \047s/-[0-9]+-g[a-f0-9]+$//\047'

# show new commits after last fetch
$gc alias.lc              $'log ORIG_HEAD.. --stat --no-merges'
$gc alias.log-fetched     $'log ..FETCH_HEAD --stat --no-merges'
# this should probably be log-remote and figure out the tracking remote
$gc alias.log-origin      $'log ..origin --stat --no-merges'

$gc alias.logstat         $'log --stat'
$gc alias.logst           $'log --stat --no-merges'

$gc alias.log-since-tag   $'!_() { tag=`git last-tag`; revs=$tag..HEAD; git log $* $revs; echo "\n=== $revs ===\n"; git tag-summary $tag; }; _'

# condense log output (modified from http://coderwall.com/p/euwpig)
$gc alias.lg               "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%aN%Creset %C(blue)<%aE>%Creset' --abbrev-commit"
$gc alias.lgpcw           $'!git lg -p --color-words=.'

# ls-files doesn't tab-complete, so just shorten it
$gc alias.ls              $'ls-files'

$gc alias.merge-delete    $'!_() { git merge "$1"; git branch -d "$1"; }; _'

# provide rebasing music (https://coderwall.com/p/at9bya)
#$gc alias.mav             $'!afplay ~/Music/Danger\\ Zone.mp3 & LASTPID=$! \ngit rebase -i $1 \nkill -9 $LASTPID\n true'

# what new commits have been created by the last command (like "git pull")
$gc alias.new             $'!_() { git log $1@{1}..$1@{0} "$@"; }; _'

$gc alias.prune-all       $'!git remote | xargs -n 1 git remote prune'

$gc alias.pulls           $'!git pull; test -f ${GIT_DIR:-.}/.gitmodules && git submodule update'

# pum doesn't seem to be storing the fetch, so do both
$gc alias.pum             $'!git fetch upstream; git pull upstream master'

$gc alias.branch-to-remote       $'!_() { branch=${1:-`git current-branch`} remote=${2:-origin}; git config branch.$branch.remote $remote; git config branch.$branch.merge refs/heads/$branch; }; _'
$gc alias.branch-track    $'!_() { branch=${1} remote=${2:-origin}; git branch --track $branch remotes/$remote/$branch; }; _'

# load pull requests as remote branches (github++)
# https://gist.github.com/piscisaureus/3342247
$gc alias.fetch-pr        $'!_() { remote="${1:-origin}"; git fetch "$remote" "+refs/pull/*/head:refs/remotes/$remote/pr/*"; }; _'
$gc alias.branch-pr       $'!_() { branch="$1"; pr="$2"; remote="${3:-origin}"; git co -b "$branch" -t "refs/remotes/$remote/pr/$pr"; }; _'

# run daemon (use !git to run from repo root) then try git ls-remote
$gc alias.serve           $'!git daemon --reuseaddr --verbose  --base-path=. --export-all ./.git'

$gc alias.st              $'!_() { if [ $# -gt 0 ]; then git status "$@"; else git status && git stash list | sed -re "s/^([^:]+):/\\\033[33m\\1\\\033[00m:/"; fi; }; _'
$gc alias.s               $'status -s -b -u'
$gc alias.tag-summary     $'!_() { git show --summary ${1:-`git last-tag`}; }; _'

# whois takes a name or email
$gc alias.whois           $'!_() { git log -i -1 --pretty="format:%an <%ae>\n" --author="$1"; }; _'
# whatis takes a commit name
$gc alias.whatis          $'show -s --pretty="tformat:%h (%s, %ad)" --date=short'

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
