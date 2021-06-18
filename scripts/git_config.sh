#!/bin/bash
# vim: set fdm=marker:

# Turn off xtrace that helpers turns on (too much noise for this).
. "${0%/*}/.helpers.sh" +x

file="$HOME/.gitconfig"
umask 0077
touch "$file"
chmod 0600 "$file"

# if there's no modeline put one there
if ! grep -qE '^# vim: .+:$' "$file"; then
  # set ro to remind me not to edit the file
  [[ -s "$file" ]] || echo > "$file"
  sed -i -e $'1 i\\\n# vim: set ro ts=2:' "$file"
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
          grep_color match      $color
          grep_color context    $color
        ;;
      ms) grep_color match      $color;;
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

config init.defaultBranch main

config color.ui          auto

config core.excludesFile ~/.excludes
config core.attributesfile ~/.gitattributes
config core.symlinks false
config user.branch-prefix rwstauner/

cat <<EOF > ~/.gitattributes
# generated.
*.json diff=json
sanctum/** diff=sanctum

*.java diff=java
*.pl diff=perl
*.pm diff=perl
*_spec.rb diff=rspec
*.sh whitespace=indent,trail,space eol=lf

# https://gist.github.com/tekin/12500956bd56784728e490d8cef9cb81
*.c     diff=cpp
*.h     diff=cpp
*.c++   diff=cpp
*.h++   diff=cpp
*.cpp   diff=cpp
*.hpp   diff=cpp
*.cc    diff=cpp
*.hh    diff=cpp
*.cs    diff=csharp
*.css   diff=css
*.html  diff=html
*.xhtml diff=html
*.ex    diff=elixir
*.exs   diff=elixir
*.go    diff=golang
*.py    diff=python
*.md    diff=markdown
*.rb    diff=ruby
*.rake  diff=ruby
*.rs    diff=rust
EOF

# https://www.git-tower.com/blog/make-git-rebase-safe-on-osx/
config core.trustctime   false

config pull.rebase false # merge (default)
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
config diff.json.textconv    'sh -c '\''jq "${JSON_DIFF_JQ:-.}" "$@" || cat "$@"'\'' --'
config diff.sanctum.textconv 'sh -c '\''test -n "$GIT_DIFF_FILE" && t="${GIT_DIFF_FILE#sanctum/}" && t="${t%%/*}" && cd sanctum && sanctum view -t "$t" "${1#sanctum/}" || cat "$@"'\'' --'
config diff.strings.textconv 'strings'
config diff.ziplist.textconv 'unzip -l'
config diff.pdftext.textconv 'pdftotext'
config diff.rspec.xfuncname  '^[ \t]*((RSpec|describe|context|it|before|after|feature|scenario|background)[ \t].*)$'

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

# ls-files -m doesn't show changes staged for commit (status does).
# The value of this command is to interact with files,
# so print the new name for renames (R) and skip deletes (D).
alias changed         $'!git status --porcelain | awk \x27$1 ~ /[MA]/ { print $2 } $1 ~ /[R]/ { print $4 }\x27'

alias change-id       $'!git show --no-patch "$@" | awk \x27/^ {4}Change-Id: I/ { print $2 }\x27'

alias consolidate     '!git gc --aggressive && git repack'

alias civ             'commit -v'
alias amend           'commit -v -n --amend'

alias co              'checkout'
alias cob             'checkout -b'
alias com             '!git checkout `git main-branch`'

alias commit-vars     '!n="${1:-`git config user.name`}"; e="${2:-`git config user.email`}"; echo GIT_COMMITTER_NAME=\"$n\" GIT_COMMITTER_EMAIL=\"$e\" GIT_AUTHOR_NAME=\"$n\" GIT_AUTHOR_EMAIL=\"$e\"'

alias cobt            '!git checkout -tb "$1" origin/"$1"'

# TODO: heredoc?
alias cpan-mailmap    $'!echo "`git config user.name` <`awk \047/^user / { print tolower($2) }\047 ~/.pause`@cpan.org> <`git config user.email`>"'

alias clone-dest      '!echo "${2:-${1##*/}}"'

# clone repo, make remote "origin" for first arg and "upstream" for second
alias clone-fork      '!fork=$1 upstream=$2; forkdir=${3:-${fork##*/}}; forkdir=${forkdir%.git}; git clone $fork; cd ${forkdir}; git remote add upstream $upstream'

# git rev-parse --default master --symbolic-full-name HEAD
# git rev-parse --abbrev-ref HEAD
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
  config "alias.last$alias"  "$prefix${prefix:+ }last -p $suffix"
  config "alias.lf$alias"     "${prefix:-! git }${prefix:+ }lf $suffix"
  config "alias.logp$alias"   "$prefix${prefix:+ }log -p $suffix"
  config "alias.showp$alias"  "$prefix${prefix:+ }show -p $suffix"
}

alias_diffs cw            '' $'--color-words=.'
alias_diffs cww           '' $'--color-words=\\\\w+'
alias_diffs hl            '!_() { git' '--color "$@" | diff-highlight | $PAGER; }; _'

alias diff-each        '!(cd $GIT_PREFIX && git diff --name-only -- "$@") | while read -r f; do GIT_DIFF_FILE="$f" git diff --color=always "$f"; done | $PAGER'
alias diffwithsubs     '!git submodule summary; git diff'

alias draft            'push origin HEAD:refs/drafts/master'

# the sha1 for an empty tree in case you want to compare something to a bare repo
alias empty-tree-sha1  'hash-object -t tree /dev/null'

#alias change-github-username $'!sed -i -re \047s/(github.com:)magnificent-tears/\\1rwstauner/\047 .git/config'

alias follow           'log --follow'

# Create a script that can be verified and then piped to sh.
# TODO: split args b/t log and fp with `--`.
alias format-patch-script  $'!file="$1"; shift; git log --oneline "$file" | perl -e \'print reverse <STDIN>\' | perl -lne \'BEGIN { @opts = splice @ARGV } ($c, $s) = split / /, $_, 2; print q[git format-patch -n --start-number ], ++$patch, qq[ @opts -1 $c # $s]\' -- "$@"'

alias clone-x          '!git clone "$@" && (cd `git clone-dest "$@"` && git maybe repo-setup)'

# filenames at the top: --heading --break ?
alias grep-todo       'grep -iE "to.?do|fix.?me"'

alias homepage-metacpan    '!curl -v -d "login=`git config github.user`&token=`git config github.token`&values[homepage]=http://metacpan.org/release/${PWD##*/}" "https://github.com/api/v2/json/repos/show/rwstauner/${PWD##*/}"'

alias hubclone        '!git clone git@github.com:`git config github.user`/"$1".git'

# uses patchutils/interdiff to see upstream modifications b/t two commits (origin/master and local branch)
alias intercommit     '!git show "$1" > .git/commit1 && git show "$2" > .git/commit2 && interdiff .git/commit[12] | less -FRS'

alias initial-commit  '!git rev-list --all | tail -n 1'

alias k                '!gitk'
# Gitv (from the command line seems to require an argument)
alias kv               '!vim -c "silent Gitv" `if test "$#" -gt 0; then echo "$@"; else echo .; fi`'

alias lf               'log --pretty=fuller --stat -p -w'
alias last             '!git lf -n 1 -U10'

# Print added, modified, the new name of renames, not deletes, and limit to files that still exist.
alias last-changed    $'!git show --pretty= --name-only --diff-filter=ACMRT "$@" | gxargs -r ls -1 2> /dev/null'

# there must be a better way
alias last-sha        $'!git show HEAD --oneline | head -n1 | awk \047{print $1}\047'
alias last-tag        $'!git describe --tags --long | sed -re \047s/-[0-9]+-g[a-f0-9]+$//\047'

alias log1       'log --oneline'
alias logp       'log -p'

alias log-changed     'log --name-only'
alias logdiff    'log -p --full-diff --stat'

# The --stat-name-width=${COLUMNS:-80} arg doesn't seem to help very much.
logst='log --stat --no-merges'
alias logstat         'log --stat'
alias logst           "$logst"

# show new commits after last fetch
alias log-pulled      "$logst ORIG_HEAD.."
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
# alias lsgrep           '!git ls-files | grep --color=always "$@" | $PAGER'
#alias lsgrep           '!pattern="$1"; shift; git ls-files "$@" | grep --color=always "$pattern" | $PAGER'

alias main-branch      '!if [ "`git config branch.main.merge`" = "refs/heads/main" ]; then echo main; else echo master; fi'

alias maat             '!git log --pretty=format:"[%h] %an %ad %s" --date=short --numstat'

alias has              '!cmd="$1"; shift; git config "alias.$cmd" >&- || command -v "git-$cmd" >&-'
alias maybe            '!if git has "$1"; then git "$@"; fi'

alias merge-delete     '!git merge "$1" && git branch -d "$1"'

alias mine             '!git log --author=`git config user.email`'
alias minest           '!git mine --stat --no-merges'

# provide rebasing music (https://coderwall.com/p/at9bya)
#alias mav             $'!afplay ~/Music/Danger\\ Zone.mp3 & LASTPID=$! \ngit rebase -i $1 \nkill -9 $LASTPID\n true'

# https://blog.afoolishmanifesto.com/posts/git-aliases-for-your-life/
# git rebase --root --onto origin/master -i --autosquash
# gitk $(cat .git/MERGE_HEAD) $(cat .git/ORIG_HEAD) "$@" &
# gitk ^origin/master HEAD

# what new commits have been created by the last command (like "git pull")
alias new              '!git log $1@{1}..$1@{0} "$@"'

# alias patch            '!git --no-pager diff --no-color "$@"'

# FIXME: There's an api for this.
alias prune-all        '!git remote | xargs -n 1 git remote prune'

alias prune-branches   '!main="`git main-branch`"; git com; git rebase-branches "$@"; for branch in $(git branch --merged "$main" | cut -c 3- | grep -vFx "$main"); do git branch -d "$branch"; done'

alias pulp             '!echo just here to avoid tab-completing "pull"'

# pum doesn't seem to be storing the fetch, so do both
alias pum              '!git fetch upstream; git pull upstream `git main-branch`'

alias push-topic       '!git push origin "`git config remote.origin.push`,topic=$*"'
alias pusht            '!git push "$@"; git push --tags "$@"'
alias branch-prefix    '!git config remote."${1:-origin}".url | grep -q rwstauner || git config user.branch-prefix'
alias pushup           '!git push -u "${1:-origin}" HEAD:"`git branch-prefix`${2:-`git current-branch`}"'

alias branch-to-remote  '!branch=${1:-`git current-branch`} remote=${2:-origin}; git config branch.$branch.remote $remote; git config branch.$branch.merge refs/heads/$branch'
alias branch-track      '!branch=${1} remote=${2:-origin}; git branch --track $branch remotes/$remote/$branch'

# load pull requests as remote branches (github++)
# https://gist.github.com/piscisaureus/3342247
alias fetch-pr         '!remote="${1:-origin}"; git fetch "$remote" "+refs/pull/*/head:refs/remotes/$remote/pr/*"'
alias branch-pr        '!branch="$1"; pr="$2"; remote="${3:-origin}"; git co -b "$branch" -t "refs/remotes/$remote/pr/$pr"'

alias rb               'rebase --autostash'
alias rbm              '!if [ $# -gt 0 ] && [ "x$*" != "x-i" ]; then echo "no args for rbm"; exit 1; fi; git rebase --autostash `git main-branch` "$@"'

# Rebasing a cherry-picked branch will squash the duplicated commit.
# Wait a moment after a failure for git to clean up.
alias rebase-branches  '!main=`git main-branch`; [ $# -gt 0 ] || set -- $(git branch --no-merged "$main" | grep -vE "\bwip-"); for branch in "$@"; do echo " # $branch #"; git rebase -q "$main" "$branch" || { git rebase --abort; sleep 1; } done; git checkout "$main"'

# Since git operates from the project root dir `pwd` also works.
#$gc alias.root            $'!pwd'
alias root             'rev-parse --show-toplevel'

# run daemon (use !git to run from repo root) then try git ls-remote
alias serve            '!git daemon --reuseaddr --verbose  --base-path=. --export-all ./.git'

alias st              $'!if [ $# -gt 0 ]; then git status "$@"; else git status && git stash list | sed -e "s/^/\\\033[33m/" -e "s/:/\\\033[00m:/"; fi'
alias stx              '!git st; git bv; echo ignored:; git summarize-other'

alias subup            '!test -f ${GIT_DIR:-.}/.gitmodules && git submodule update'

alias s                'status -s -b -u'

alias summarize-other  "!git ls-files -o | perl -ne '\$c = m{^([^/]+)/} ? \$1 : q[.]; \$d{\$c}++; END { for ( sort keys %d ){ printf qq[%6d %s/\\n], \$d{\$_}, \$_ } }'"

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

alias these            '!cmd="$1"; shift; for i in "$@"; do (cd "$i" && eval git "$cmd"); done'

alias topic            '!git checkout -b "$1" "`git main-branch`"'

alias up               'pull --all --prune --rebase --autostash'
alias ups              '!git up; git subup'
alias upp              '!git up; git new | git maybe process-merged; git prune-branches; git bv'

alias url              '!printf "%s/%s\n" "`git config remote.origin.url | sed -E "s,[^:/.]+@([^:]+):,https://\1/,; s/\.git$//"`" "blob/master/$1"'

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
