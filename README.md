# NAME

Datahub::Factory::Importer::VKC - Import data from the [CollectiveAccess](http://collectiveaccess.org/) instance of the [VKC](http://www.vlaamsekunstcollectie.be/)

# SYNOPSIS

    use Datahub::Factory::Importer::VKC;
    use Data::Dumper qw(Dumper);

    my $vkc = Datahub::Factory::Importer::VKC->new(
    );

    $vkc->importer->each(sub {
        my $item = shift;
        print Dumper($item);
    });

# DESCRIPTION

Datahub::Factory::Importer::VKC uses [Catmandu](http://librecat.org/Catmandu/) to fetch a list of records
from the  [CollectiveAccess](http://collectiveaccess.org/) instance of the [VKC](http://www.vlaamsekunstcollectie.be/).
It returns an [Importer](https://metacpan.org/pod/Catmandu::Importer).

# PARAMETERS

# ATTRIBUTES

- `importer`

    A [Importer](https://metacpan.org/pod/Catmandu::Importer) that can be used in your script.

# AUTHOR

Pieter De Praetere &lt;pieter at packed.be >

# COPYRIGHT

Copyright 2017- PACKED vzw

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[Datahub::Factory](https://metacpan.org/pod/Datahub::Factory)
[Datahub::Factory::CollectiveAccess](https://metacpan.org/pod/Datahub::Factory::CollectiveAccess)
[Catmandu](https://metacpan.org/pod/Catmandu)
