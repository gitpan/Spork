package Spork::Command;
use strict;
use warnings;
use Spork '-base';
use IO::All;

sub init {
    my $self = shift;
    $self->use_class('config');
}

sub boolean_arguments { qw( -new -make -start) }
sub process {
    my $self = shift;
    my $args = $self->parse_arguments(@_);
    return $self->new_spork if $args->{-new};
    return $self->make_spork if $args->{-make};
    return $self->start_spork if $args->{-start};
    return $self->usage;
}

sub new_spork {
    my $self = shift;
    my @files = io('.')->all;
    die "Can't make new spork in a non-empty directory\n"
      if @files;
    $self->use_class('slides');
    warn "Extracting sample slideshow: Spork.slides...\n";
    $self->slides->extract_files;
    warn "Extracting sample configuration file: config.yaml...\n";
    $self->config->extract_files;
    warn "Done. Now edit these files and run 'spork -make'.\n\n"
}

sub make_spork {
    my $self = shift;
    $self->use_class('template');
    unless (-e $self->template->extract_to) {
        warn "Extracting template files...\n";
        $self->template->extract_files;
    }
    $self->use_class('slides');
    warn "Creating slides...\n";
    $self->slides->make_slides;
    warn "Slideshow created! Now run try running 'spork -start'.\n\n";
}

sub start_spork {
    my $self = shift;
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
