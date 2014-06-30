#perl -C -le 'print map{chr}0151,32,0x2764,040,map{ord}split//,($^X=~m#([^/\\]+)$#)[0]'

#export HARNESS_SUBCLASS=TAP::Harness::Restricted

export NOPASTE_NICK=rwstauner
export NOPASTE_SERVICES='Gist Shadowcat Pastie Snitch'

function shadowpaste () {
  # TODO: connect to channel and /invite shadowpaste
  nopaste -s Shadowcat -c "$1" ${2:+-d "$2"};
}

# LWP 6.00 breaks CPAN::Reporter (when using Metabase Transport)
# cert purchased on 2011/03/15
#alias cpan='env PERL_LWP_SSL_VERIFY_HOSTNAME=0 cpan'

# get the PERL5LIB, but don't set the install paths (cpanm handles that)
# usage of local::lib is currently undecided thanks to perlbrew...
#eval $(perl -Mlocal::lib | grep PERL5LIB)
#eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

#export PERL_UNICODE=AS

# Only load the default perlbrew environment if perlbrew isn't already in use.
if [[ -z "$PERLBREW_PERL" ]]; then
for pbparent in $HOME/perl5 /opt/perl5 /opt /usr/local; {
  perlbrewrc="$pbparent/perlbrew/etc/bashrc"
  [[ -r "$perlbrewrc" ]] && { source "$perlbrewrc"; break; }
}
unset pbparent
fi

# after perlbrew
which setup-bash-complete &> /dev/null && . setup-bash-complete

latest_perl_file () {
  perl -e '
    $file = pop;
    $exec = $ARGV[0] eq "-x" && ($file =~ m-([^/]+)$-)[0];
    # Grab the first number.number in the path.
    sub v { ($_[0] =~ /\b(?:5\.)? (\d+(\.\d+)?)/x)[0] }
    sub find {
      my ($dir) = @_;
      chdir($dir);
      map { [v($_), (m-([^/]+)-)[0], "$dir/$_"] } glob("*/$file")
    }
    # reverse sort by 5.(x.y)
    @found = sort { $b->[0] <=> $a->[0] }
      find("$ENV{HOME}/.perlbrew/libs"),
      find("$ENV{PERLBREW_ROOT}/perls");
    #use Data::Dumper; print STDERR Dumper(\@found);
    printf( $exec
      ? ("perlbrew exec --with %s -q -- %s\n", $found[0]->[1], $exec)
      : ("%s\n", $found[0]->[2])
    );
  ' -- "$@"
}

# Always use the best App::Uni we can.
alias uni=`latest_perl_file -x bin/uni || which uni`
# Enable ack even if we're on a perlbrew that doesn't have it.
alias ack=`latest_perl_file -x bin/ack || which ack`

# dzil aliases
  function dzil () {
    case "$1" in
      new)
        echo "$*" | grep -E -- '-P .+' || { echo 'use -P!'; return 1; };
        command dzil "$@";;
      installm)
        local dest=""
        if grep -F '@AutoLookout' dist.ini; then dest="$HOME/perl5-autolookout"; fi
        command dzil install --install-command="cpanm -v -i . ${dest:+-l }$dest";;
      *)
        command dzil "$@";;
    esac
  }

# shell aliases for perl commands
alias buzzword='perl -MAcme::MetaSyntactic=buzzwords -le "print metaname"'
alias gmstamp='perl -le '\''use Time::Stamp q[gmstamp].($ARGV[0]=~/^-/?shift(@ARGV):q[]) => @ARGV?{@ARGV}:(); print gmstamp'\'' --'
#alias date-iso8601='perl -MTime::Stamp=gmstamp -le print+gmstamp'

# thanks oalders!
alias penv='perl -MDDP -e "p(%ENV)"'

alias alternate='perl -ne "print( qq/\033[/ . ( \$. % 2 ? q/33/ : q/36/ ). q/m/ . \$_ . qq/\033[0m/ );"'

which base64 &> /dev/null || \
  alias base64='perl -MMIME::Base64 -0777 -sne "print \$d ? decode_base64(\$_) : encode_base64(\$_)" --'

# sometimes perldoc doesn't like en_US.utf8
#alias perldoc='env LANG=en_US perldoc'

#alias podserver='{ sleep 2; $BROWSER http://localhost:8088/@frames; } & pgrep pod_server || { pod_server -s left -f ${1:-perl}; sleep 1; };'
#alias podserver='{ sleep 2; $BROWSER http://localhost:4998; } & plackup -p 4998 -e "my \$app = require Pod::POM::Web::PSGI"'

function podhtmlview() { local u="$1"; [[ ${u:0:1} == "/" ]] || u="$PWD/$u"; firefox "http://localhost/podhtml.cgi?pod=$u"; }

function mversion() { if [ $# -eq 0 ]; then m=${PWD##*/}; else m="$1"; fi; `which mversion` ${m//-/::}; }

function grep_pm() {
  #zgrep --color=auto "$@" ~/perl5/cpan/mini/modules/02packages.details.txt.gz;
  var='$F[0]'
  if [[ "x$1" == "x-a" ]]; then
    shift
    var='$_'
  fi
  zcat ~/perl5/cpan/mini/modules/02packages.details.txt.gz | \
    perl -MTerm::ANSIColor=colored -ane 'BEGIN { $re = qr/${\shift(@ARGV)}/i } if( '"$var"' =~ $re ){ s/($re)/colored($1,"bold yellow")/ge; print }' "$*"
}

# tests
function prove () {
  command prove "$@"
  notify_result -i "$HOME/data/images/tech/perlfoundation-sticker-logos3.png"
}

# test coverage
function cover_tests () {
  cover -delete; #rm -rf cover_db/;
  PERL5OPT=-MDevel::Cover perl -Ilib "$@" 2> /dev/null;
  cover;
}
function prove_coverage () {
  cover -delete;
  # hide Devel::Cover warnings about Moose, et al.
  #HARNESS_PERL_SWITCHES="-I$HOME/perl5/local-lib-5.14-devel-cover/lib/perl5 -MDevel::Cover" prove --color "$@" 2>&1 | grep -v "Devel::Cover: Can't open";
  HARNESS_PERL_SWITCHES="-MDevel::Cover\\ 0.89" prove --color "$@" 2>&1 | grep -v "Devel::Cover: Warning: can't open";
  cover;
}

# move fg to bg so we can see whitespace changes
function perltidydiff () {   perltidy < "$1" | git diffcw --no-index "$1" - | perl -pe 's/\033\[3(\d)m/\033[4$1m/g'; }

# get the pm file rather than the pod file (if they're different)
function vim_pm () {
  pm=`perldoc -ml "$@"`
  if [[ -e "$pm" ]]; then
    vim "$pm"
  else
    # check if the module exists and just isn't installed
    grep_pm "$@" || echo " $* not found"
  fi
}

# exuberant ctags: http://ctags.sourceforge.net/
alias ctags-perl='ctags -f tags --recurse --totals --languages=Perl --langmap=Perl:+.t lib t/lib'

# Detect output encoding.
alias mp3info2='mp3info2 -e 3'

alias human_bytes='perl -MFormat::Human::Bytes -le "print Format::Human::Bytes->base2(shift)"'
