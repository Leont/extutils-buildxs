package ExtUtils::BuildXS;
use strict;
use warnings FATAL => 'all';

use Carp qw/croak/;
use ExtUtils::CBuilder;
use ExtUtils::ParseXS qw/process_file/;

use ExtUtils::BuildXS::File;

sub new {
	my ($class, %options) = @_;
	exists $options{$_} or croak "option $_ is not defined" for qw/config version/;
	return bless \%options, $class;
}

sub infer {
	my ($self, $file) = @_;
	return ExtUtils::BuildXS::File->new($self, $file);
}

sub compile_xs {
	my ($self, $file, %args) = @_;
	return process_file(filename => $file, prototypes => 0, output => $args{outfile});
}

sub cbuilder {
	my $self = shift;

	return $self->{_cbuilder} ||= ExtUtils::CBuilder->new(config => $self->{config}->values_set, quiet => !$self->{verbose})
}

sub have_c_compiler {
	my $self = shift;
	$self->{_have_c_compiler} = eval { $self->cbuilder->have_compiler } if not defined $self->{_have_c_compiler};
	return $self->{_have_c_compiler};
}

sub compile_c {
	my ($self, $file, %args) = @_;
	croak "Error: no compiler detected to compile '$file'.	Aborting" if !$self->have_c_compiler;
	my $builder = $self->cbuilder;
	my $obj_file = $builder->object_file($file);
	return $builder->compile(%args, source => $file, object_file => $obj_file);
}

sub link_c {
	my ($self, $spec, $objects) = @_;

	$objects ||= [];
	return $self->cbuilder->link(objects => [$spec->{obj_file}, @{$objects}], map { ($_ => $spec->{$_}) } qw/module_name lib_file extra_linker_flags/ ); 
}

1;

__END__

# ABSTRACT: A module for compiling XS code
