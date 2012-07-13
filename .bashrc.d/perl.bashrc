export NOPASTE_NICK=rwstauner
export NOPASTE_SERVICES='Gist Shadowcat Pastie Snitch'

# LWP 6.00 breaks CPAN::Reporter (when using Metabase Transport)
# cert purchased on 2011/03/15
#alias cpan='env PERL_LWP_SSL_VERIFY_HOSTNAME=0 cpan'

# get the PERL5LIB, but don't set the install paths (cpanm handles that)
# usage of local::lib is currently undecided thanks to perlbrew...
#eval $(perl -Mlocal::lib | grep PERL5LIB)

#export PERL_UNICODE=AS

perlbrewrc="$HOME/perl5/perlbrew/etc/bashrc"
[[ -r "$perlbrewrc" ]] && source "$perlbrewrc"

# after perlbrew
which setup-bash-complete &> /dev/null && . setup-bash-complete

# dzil aliases
if which dzil &> /dev/null; then
  function dzil () {
    local dzil="`which dzil`"
    case "$1" in
      installm)
        local dest=""
        if grep -F '@AutoLookout' dist.ini; then dest="$HOME/perl5-autolookout"; fi
        $dzil install --install-command="cpanm -v -i . ${dest:+-l }$dest";;
      *)        $dzil "$@";;
    esac
  }
fi

# shell aliases for perl commands
alias buzzword='perl -MAcme::MetaSyntactic=buzzwords -le "print metaname"'
alias gmstamp='perl -e "use Time::Stamp gmstamp => {@ARGV}; print gmstamp, qq[\n]"'

alias alternate='perl -ne "print( qq/\033[/ . ( \$. % 2 ? q/33/ : q/36/ ). q/m/ . \$_ . qq/\033[0m/ );"'

which base64 &> /dev/null || \
  alias base64='perl -MMIME::Base64 -0777 -sne "print \$d ? decode_base64(\$_) : encode_base64(\$_)" --'

alias perl1='perl -CSDLA -Mcharnames=:full -MData::Printer -MData::Dumper -MYAML::Any -MClass::Autouse=:superloader -E "sub D(\$){ print Dumper(shift) } sub Y(\$){ print Dump(shift) } sub P(\$) { &p(shift) }"'

# sometimes perldoc doesn't like en_US.utf8
alias perldoc='env LANG=en_US perldoc'

# alias podspelltest='perl -MTest::More -MTest::Spelling -e "set_spell_cmd(q[aspell list]); all_pod_files_spelling_ok(@ARGV)"'
alias podspelltest='perl -MTest::More -MTest::Spelling -MPod::Wordlist::hanekomu -e "all_pod_files_spelling_ok(@ARGV)"'

#alias podserver='{ sleep 2; $BROWSER http://localhost:8088/@frames; } & pgrep pod_server || { pod_server -s left -f ${1:-perl}; sleep 1; };'
#alias podserver='{ sleep 2; $BROWSER http://localhost:4998; } & plackup -p 4998 -e "my \$app = require Pod::POM::Web::PSGI"'

function podhtmlview() { local u="$1"; [[ ${u:0:1} == "/" ]] || u="$PWD/$u"; firefox "http://localhost/podhtml.cgi?pod=$u"; }

function mversion() { if [ $# -eq 0 ]; then m=${PWD##*/}; else m="$1"; fi; `which mversion` ${m//-/::}; }

function grep_pm() { zgrep --color=auto "$@" ~/perl5/cpan/mini/modules/02packages.details.txt.gz; }

# test coverage
function cover_tests () {
  cover -delete; #rm -rf cover_db/;
  PERL5OPT=-MDevel::Cover perl -Ilib "$@" 2> /dev/null;
  cover;
}
function prove_coverage () {
  cover -delete;
  # hide Devel::Cover warnings about Moose, et al.
  HARNESS_PERL_SWITCHES="-I$HOME/perl5/local-lib-5.14-devel-cover/lib/perl5 -MDevel::Cover" prove --color "$@" 2>&1 | grep -v "Devel::Cover: Can't open";
  cover;
}

function perltidydiff () {   perltidy < "$1" | git diffcw --no-index "$1" - | perl -pe 's/\033\[3(\d)m/\033[4$1m/g'; }

# get the pm file rather than the pod file (if they're different)
function vim_pm () {
  pm=`module_info "$@" | awk '/^File:/ { print $2 }'`;
  [[ -n "$pm" ]] || pm=`perldoc -l "$@"`
  pm="${pm/.pod/.pm}"
  if [[ -e "$pm" ]]; then
    vim "$pm"
  else
    vim -c 'set ft=perl' -c "norm iuse $1;" -c 'norm B\f' -c 'bunload! 1';
  fi
}
