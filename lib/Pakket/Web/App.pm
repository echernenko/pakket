package Pakket::Web::App;
# ABSTRACT: The Pakket web application

use Dancer2 0.204001 'appname' => 'Pakket::Web'; # decode_json
use Log::Any qw< $log >;
use List::Util qw< first >;
use Path::Tiny ();
use Pakket::Web::Repo;
use constant {
    'PATHS' => [
        $ENV{'PAKKET_WEB_CONFIG'} || (),
        '~/.pakket-web.json',
        '/etc/pakket-web.json',
    ],
};

sub setup {
    my ( $class, $config_file ) = @_;

    $config_file //= first { Path::Tiny::path($_)->exists } @{ PATHS() }
        or die $log->fatal(
            'Please specify a config file: PAKKET_WEB_CONFIG, '
          . '~/.pakket-web.json, or /etc/pakket-web.json.',
        );

    my $config = decode_json( Path::Tiny::path($config_file)->slurp_utf8 );

    foreach my $repo_config ( @{ $config->{'repositories'} } ) {
        Pakket::Web::Repo->create($repo_config);
    }

    get '/info' => sub {
        my @repositories =  map { { 'type' => $_->{'type'},
                                    'path' => $_->{'path'} } }
                                @{ $config->{'repositories'} };
        return encode_json({
                'version' => $Pakket::Web::App::VERSION,
                'repositories' => [@repositories],
                });
    };

    # status page
    get '/status' => sub {
        # the data should be processed here
        # like on ine 28
        # foreach my $repo_config
        # and we need TODO:
        # 1. form array of modules (by merging spec and sources)
        # 2. cut "perl/" prefix
        # 3. loop over parcel repos and get data regarding parcels
        # 4. create a hash to be consumed by UI for rendering a table
        my $dirname = dirname(__FILE__);
        my $template = Path::Tiny::path($dirname.'/views/status.html');
        return $template->slurp_utf8;
    };

}

1;

__END__
