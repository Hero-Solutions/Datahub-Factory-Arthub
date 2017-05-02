package Datahub::Factory::Module::PID;

use Datahub::Factory::Sane;

use Datahub::Factory::Module::PID::CloudFiles;
use Datahub::Factory::Module::PID::WebFile;

use File::Basename qw(fileparse);

use Catmandu;
use Moo;

has pid_module         => (is => 'ro', default => 'lwp');
has pid_username       => (is => 'ro');
has pid_password       => (is => 'ro');
has pid_lwp_realm      => (is => 'ro');
has pid_lwp_url        => (is => 'ro');
has rcf_container_name => (is => 'ro');
has rcf_object         => (is => 'ro');

has client       => (is => 'lazy');
has path         => (is => 'lazy');

sub _build_path {
    my $self = shift;
    return $self->client->path;
}

sub _build_client {
    my $self = shift;
    if ($self->pid_module eq 'lwp') {
        return Datahub::Factory::Module::PID::WebFile->new(
            url      => $self->pid_lwp_url,
            username => $self->pid_username,
            password => $self->pid_password,
            realm    => $self->pid_lwp_realm
        );
    } elsif ($self->pid_module eq 'rcf') {
        return Datahub::Factory::Module::PID::CloudFiles->new(
            username       => $self->pid_username,
            api_key        => $self->pid_password,
            container_name => $self->rcf_container_name,
            object         => $self->rcf_object,
        );
    }
}

sub temporary_table {
    my ($self, $csv_location, $id_column) = @_;
    my $store_table = fileparse($csv_location, '.csv');

    my $importer = Catmandu->importer(
        'CSV',
        file => $csv_location
    );
    my $store = Catmandu->store(
        'DBI',
        data_source => sprintf('dbi:SQLite:/tmp/import.%s.sqlite', $store_table),
    );
    $importer->each(sub {
            my $item = shift;
            if (defined ($id_column)) {
                $item->{'_id'} = $item->{$id_column};
            }
            my $bag = $store->bag();
            # first $bag->get($item->{'_id'})
            $bag->add($item);
        });
}

1;