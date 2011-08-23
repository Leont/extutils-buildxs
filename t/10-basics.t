#!perl

use strict;
use warnings;
use Test::More 0.88;

use ExtUtils::BuildXS;
use ExtUtils::Config;
use File::Spec::Functions qw/catfile/;

my $config = ExtUtils::Config->new;
my $builder = ExtUtils::BuildXS->new(config => $config, version => 0.001, blib => 'result');

my $spec = $builder->infer(catfile(qw/corpus test.xs/));

is($spec->module_name, 'corpus::test', 'module name is corpus::test');

ok($spec->process, 'process returns true');

ok -s $spec->lib_file;

push @INC, qw{result/arch result/lib};
ok(XSLoader::load('corpus::test', 0.001), 'Could load corpus::test');
is(corpus::test::answer(), 42, 'corpus::test::answer returned 42');

done_testing;
