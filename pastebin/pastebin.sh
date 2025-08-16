#!/bin/sh

export PERL5LIB=/usr/local/pastebin/lib
export MOJO_HOME=/usr/local/pastebin/
export MOJO_CONFIG=/usr/local/pastebin/config/pastebin.conf

exec hypnotoad -f /usr/local/pastebin/bin/pastebin.pl 2>&1
