package Spork::Config;
use strict;
use Spoon::Config '-base';
use Spoon::Installer '-base';

field const class_id => 'config';

sub default_config {
    {
        config_class => 'Spork::Config',
        hub_class => 'Spork::Hub',
        formatter_class => 'Spork::Formatter',
        template_class => 'Spork::Template',
        command_class => 'Spork::Command',
        files_class => 'Spork::Files',
        slides_class => 'Spork::Slides',

        slides_file => 'Spork.slides',
        template_directory => 'template',
    }
}

sub file_filter {
    my $self = shift;
    my $file_content = shift;
    $self->use_class('template', %{$self->default_config});
    $self->template->process(\$file_content);
}

1;
__DATA__
__config.yaml__
# Please read this file over and set the values to your own.
presentation_topic: Spork
presentation_title: Spork - The Kwiki Way To Do Slideshows
presentation_place: Portland, Oregon
presentation_date: March 25nd, 2004
author_name: Brian Ingerson
author_email: ingy@cpan.org
author_webpage: http://search.cpan.org/~ingy/
copyright_string: Copyright &copy; 2004 Brian Ingerson

# You *do* like hotpink, don't you?
banner_bgcolor: hotpink

# You don't need to change these ones, but you can
slides_file: [% slides_file %]
template_directory: [% template_directory %]
slides_directory: slides

# This is set up for OS X. All it does is start the browser for 'spork -start'.
start_command: open slides/start.html

# If you change this one, you are an advanced user!
formatter_class: [% formatter_class %]
