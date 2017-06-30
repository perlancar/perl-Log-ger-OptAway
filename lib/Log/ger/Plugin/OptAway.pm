package Log::ger::Plugin::OptAway;

# DATE
# VERSION

use strict;
use warnings;

sub get_hooks {
    my %conf = @_;

    return {
        after_install_routines => [
            __PACKAGE__, 99,

            sub {
                require B::CallChecker;
                require B::Generate;

                my %args = @_;

                # we are only relevant when targetting package
                return [undef] unless $args{target} eq 'package';

                for my $r (@{ $args{routines} }) {
                    my ($code, $name, $lnum, $type) = @$r;
                    next unless $type =~ /\Alog_/;
                    my $fullname = "$args{target_arg}\::$name";
                    if ($Log::ger::Current_Level < $r->[2]) {
                        #print "D:no-oping $fullname\n";
                        B::CallChecker::cv_set_call_checker(
                            \&{$fullname},
                            sub { B::SVOP->new("const",0,!1) },
                            \!1,
                        );
                    }
                }
                [1];
            }],
    };
}

1;
# ABSTRACT: Optimize away higher-level log statements

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::ger::Plugin->set('OptAway');
 use Log::ger;

Co demonstrate the effect of optimizing away:

 % perl -MLog::ger -MO=Deparse -e'log_warn "foo\n"; log_debug "bar\n"'
 log_warn("foo\n");
 log_debug("bar\n");
 -e syntax OK

 % perl -MLog::ger::Plugin=OptAway -MLog::ger -MO=Deparse -e'log_warn "foo\n"; log_debug "bar\n"'
 log_warn("foo\n");
 '???';
 -e syntax OK


=head1 DESCRIPTION

This plugin replaces logging statements that are higher than the current level
(C<$Log::ger::Current_Level>) into a no-op statement using L<B::CallChecker>
magic at compile-time. The logging statements will become no-op and will have
zero run-time overhead.

By default, since C<$Current_Level> is pre-set at 3 (warn) then C<log_info()>,
C<log_debug()>, and C<log_trace()> calls will be turned into no-op.

Caveats:

=over

=item * must be done at compile-time

=item * only works when you are using procedural style

=item * once optimized away, subsequent logger reinitialization at run-time won't take effect

=back
