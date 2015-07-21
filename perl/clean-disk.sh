#!/bin/bash

/bin/rm -rf ~/.cpan/{build,sources}/ ~/.cpanm/{sources,work}

find ~/data/perl5/cpan/mini/authors/id/ -type f -atime +90 -delete
