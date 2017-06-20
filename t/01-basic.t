#!perl

use strict;
use warnings;
use Test::More 0.98;

package My::P1;
use Log::ger;
use Log::ger::OptAway;

package main;

my $str = "";
require Log::ger::Output;
Log::ger::Output->set('String', string => \$str);

My::P1::log_warn("warn");
My::P1::log_debug("debug");
is($str, "warn\n");

Log::ger::set_level(5);

$str = "";
My::P1::log_warn("warn");
My::P1::log_debug("debug");
is($str, "warn\n");

DONE_TESTING:
done_testing;
