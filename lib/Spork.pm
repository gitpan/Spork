package Spork;
use strict;
use Spoon '-base';
our $VERSION = '0.10';
use IO::All;

field const config_class => 'Spork::Config';

sub process_command {
    my $self = shift;
}

sub new_show {
    my $self = shift;
}

sub make_slides {
}

1;

__END__

=head1 NAME

Spork - Slide Presentations (Only Really Kwiki)

=head1 SYNOPSIS

    mkdir my-slideshow
    cd my-slideshow
    spork -new
    vim config.yaml
    vim Spork.slides
    spork -make
    spork -start

=head1 DESCRIPTION

Spork lets you create HTML slideshow presentations easily. It comes with a
sample slideshow. All you need is a text editor, a browser and a topic.

Follow the steps above, and Fanny's your aunt.

=head1 SEE ALSO

Kwiki, Spoon

=head1 AUTHOR

Brian Ingerson <INGY@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
