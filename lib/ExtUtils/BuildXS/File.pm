package ExtUtils::BuildXS::File;
use strict;
use warnings FATAL => 'all';

#use ExtUtils::Mkbootstrap qw/Mkbootstrap/;

use File::Path qw/mkpath/;
use File::Spec;
use Sub::Name;

sub new {
	my ($class, $parent, $file) = @_;

	my( $v, $d, $f ) = File::Spec->splitpath($file);
	my @d = File::Spec->splitdir($d);
	(my $file_base = $f) =~ s/\.[^.]+$//i;

	# the module name
	shift( @d ) while @d && ($d[0] eq 'lib' || $d[0] eq '');
	pop( @d ) while @d && $d[-1] eq '';

	my $src_dir = File::Spec->catpath($v, $d, '');
	my $blib = $parent->{blib} || 'blib';
	my $archdir = File::Spec->catdir($blib, 'arch', 'auto', @d, $file_base);
	my %spec = (
		source_file => $file,
		base_name   => $file_base,
		src_dir     => $src_dir,
		module_name => join('::', @d, $file_base),
		archdir     => $archdir,
#		bs_file     => File::Spec->catfile($archdir, "${file_base}.bs"),
		lib_file    => File::Spec->catfile($archdir, "${file_base}.".$parent->{config}->get('dlext')),
		c_file      => File::Spec->catfile($src_dir, "${file_base}.c"),
		obj_file    => File::Spec->catfile($src_dir, "${file_base}".$parent->{config}->get('obj_ext')),
		parent      => $parent,
	);

	return bless \%spec, $class;
}

sub process {
	my ($self, %options) = @_;
	my $parent = $self->{parent};

	$parent->compile_xs($self->source_file, outfile => $self->c_file);
	$parent->compile_c($self->c_file, defines => { VERSION => qq/"$parent->{version}"/, XS_VERSION => qq/"$parent->{version}"/ });
	mkpath($self->{archdir}, $options{verbose}, oct 755) unless -d $self->{archdir};
#	Mkbootstrap($self->{bs_file}); # Original had $BSLOADLIBS - what's that?
#	open my $fh, '>>', $self->{bs_file} or die "Couldn't open $self->{bs_file}: $!";
#	utime((time)x2, $self->{bs_file});	# touch

	return $parent->link_c($self, $options{objects});
}

for my $name (qw/source_file lib_file module_name c_file obj_file/) {
	my $sub = sub {
		my $self = shift;
		return $self->{$name};
	};
	subname($name, $sub);
	no strict 'refs';
	*{$name} = $sub;
}

1;

__END__

# ABSTRACT: A module for compiling an XS file to a shared library
