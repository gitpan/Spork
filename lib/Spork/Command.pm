package Spork::Command;
use strict;
use warnings;
use Spork '-base';
use IO::All;

sub init {
    my $self = shift;
    $self->use_class('config');
}

sub boolean_arguments { qw( -new -make -start -upgrade) }
sub process {
    my $self = shift;
    my $args = $self->parse_arguments(@_);
    return $self->new_spork if $args->{-new};
    return $self->make_spork if $args->{-make};
    return $self->start_spork if $args->{-start};
    return $self->upgrade_spork if $args->{-upgrade};
    return $self->usage;
}

sub new_spork {
    my $self = shift;
    my @files = io('.')->all;
    die "Can't make new spork in a non-empty directory\n"
      if @files;
    $self->use_class('slides');
    $self->slides->extract_files;
    $self->config->extract_files;
}

sub make_spork {
    my $self = shift;
#     my $spork = Spork->new;
#     my $hub = $spork->load_hub;
#     my $self = $hub->load_class('command');
    $self->use_class('template');
    $self->template->extract_files
      unless -e $self->template->extract_to;
    $self->use_class('slides');
    $self->slides->make_slides;
    $self->slides->copy_files;
}

sub start_spork {
    my $self = shift;
#     my $spork = Spork->new;
#     my $hub = $spork->load_hub('config.yaml');
#     my $self = $hub->load_class('command');
    my $command = $self->config->start_command
      or die "No start_command in configuration";
    warn $command, "\n";
    exec $command;
}

sub usage {
    warn <<END;
usage:
  spork -new                  # Generate a new slideshow in an empty directory
  spork -make                 # Turn the text into html slides
  spork -start                # Start the show in a browser
END
}

1;
