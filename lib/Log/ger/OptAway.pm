package Log::ger::OptAway;

# DATE
# VERSION

use strict;
use warnings;

use Log::ger ();

sub import {
    my $self = shift;

    my $caller = caller(0);

    Log::ger::add_hook(
        'after_install_routine',
        99,
        sub {
            require B::CallChecker;
            require B::Generate;

            my %args = @_;
            my $fullname = "$caller\::log_$args{str_level}";
            if ($Log::ger::Current_Level < $args{level}) {
                B::CallChecker::cv_set_call_checker(
                    \&{$fullname},
                    sub { B::SVOP->new("const",0,!1) },
                    \!1,
                );
            }
            [undef];
        },
    );
    Log::ger::setup_package($caller) if $Log::ger::Import_Args{$caller};
}

1;
# ABSTRACT: Optimize away higher-level log statements

=head1 SYNOPSIS

 use Log::ger::OptAway;
 use Log::ger;


=head1 DESCRIPTION

 % perl -MLog::ger -MO=Deparse -e'log_warn "foo\n"; log_debug "bar\n"'
 log_warn("foo\n");
 log_debug("bar\n");
 -e syntax OK

 % perl -MLog::ger::OptAway -MLog::ger -MO=Deparse -e'log_warn "foo\n"; log_debug "bar\n"'
 log_warn("foo\n");
 '???';
 -e syntax OK

This module installs a hook to replace logging call that are higher than the
current level (C<$Log::ger::Current_Level>) into a null statement. By default,
since C<$Current_Level> is pre-set at 3 (warn) then C<log_info()>,
C<log_debug()>, and C<log_trace()> calls will be turned into no-op.
