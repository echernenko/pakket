package Pakket::CLI::Command::install;
# ABSTRACT: The pakket install command

use strict;
use warnings;
use Pakket::CLI '-command';
use Pakket::Installer;
use Pakket::Log;
use Log::Any::Adapter;
use Path::Tiny      qw< path >;

sub abstract    { 'Install a package' }
sub description { 'Install a package' }

sub opt_spec {
    return (
        [
            'to=s',
            'directory to install the package in',
            { 'required' => 1 },
        ],
        [
            'from=s',
            'directory to install the packages from',
            { 'required' => 1 },
        ],
        [ 'index-file=s', 'Index file for the sources', { 'required' => 1 } ],
        [ 'verbose|v+', 'verbose output (can be provided multiple times)' ],
    );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    my $logger = Pakket::Log->cli_logger(2); # verbosity
    Log::Any::Adapter->set( 'Dispatch', dispatcher => $logger );

    $self->{'installer'}{'pakket_dir'} = $opt->{'to'};
    $self->{'installer'}{'parcel_dir'} = $opt->{'from'};
    $self->{'installer'}{'index_file'} = $opt->{'index_file'};

    @{$args} == 0
        and $self->usage_error('Must provide parcels to install');

    my @parcels = @{$args};

    $self->{'parcels'} = \@parcels;
}

sub execute {
    my $self      = shift;
    my $installer = Pakket::Installer->new(
        map( +(
            defined $self->{'installer'}{$_}
                ? ( $_ => $self->{'installer'}{$_} )
                : ()
        ), qw< pakket_dir parcel_dir index_file > ),
    );

    return $installer->install( @{ $self->{'parcels'} } );
}

1;

__END__
