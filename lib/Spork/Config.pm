package Spork::Config;
use strict;
use warnings;
use Spoon::Config '-base';
use Spoon::Installer '-base';

const class_id => 'config';

sub default_configs {
    my @configs;
    push @configs, "config.yaml"
      if -f "config.yaml";
    push @configs, "$ENV{HOME}/.sporkrc/config.yaml"
      if defined $ENV{HOME} and -f "$ENV{HOME}/.sporkrc/config.yaml";
    return @configs;
}

sub default_config {
    {
        config_class => 'Spork::Config',
        hub_class => 'Spork::Hub',
        formatter_class => 'Spork::Formatter',
        template_class => 'Spork::Template::TT2',
        command_class => 'Spork::Command',
        slides_class => 'Spork::Slides',

        slides_file => 'Spork.slides',
        template_directory => 'template/tt2',
        template_path => [ 'template/tt2' ],
    }
}

1;

__DATA__

=head1 NAME

Spork::Config - Spork Configuration Class

=head1 SETTINGS

This is a list of all the current configuration options in alphabetical order:

=over 4

=item * author_email

The presentation author's email address.

=item * author_name

The presentation author's full name.

=item * author_webpage

The presentation author's webpage.

=item * auto_scrolldown

When a multipart slide is too long for the display, force it to scroll all the
way down when you link to it.

=item * banner_bgcolor

Background color for the banner boxes at the top and bottom of each slide.

=item * character_encoding

I18N character encoding. You probably want 'utf-8'.

=item * copyright_string

A copyright message to be displayed on each slide.

=item * download_method

Which program to use when downloading images. Possible values are:

    wget - default
    curl
    lwp

=item * file_base

A path to prepend to any relative file path provided to the C<<file<...> >>
directive.

=item * file_base

A path to prepend to any relative file path provided to the C<<file<...> >>
directive.

=item * formatter_class

Perl module to be used for slides formatting. You probably won't change this
unless you are up to the task of writing your own custom formatter.

=item * image_width

This is the default width that all images in your slideshow will be scaled to.

=item * link_index

Text for link to index page.

=item * link_next

Text for link to next page.

=item * link_previous

Text for link to previous page.

=item * logo_image

A small image to put at the bottom of each slide. You can leave this value
empty if you don't have a logo.

=item * mouse_controls

If this is turned off, clicking on the page will not advance the
screen. This is useful if you like to use the mouse to hilight things
on the page.

=item * show_controls

If this is turned off, the control links (previous, index, next) will not
display.

=item * slides_directory

The directory where all your slides will be written to when you do C<spork
-make>.

=item * slides_file

The name of the file that you write all of your slides in.

=item * start_command

The command that gets executed when you type C<spork -make>.

=item * template_class

The Perl module that is used for template processing. This module also
contains the default templates that are used. Possible values are:

    Spork::Template::TT2    (Template Toolkit - default)
    Spork::Template::Mason  (HTML::Mason - by Dave Rolsky)
    Spork::Template::Simple (Simplistic version with no dependencies)

=item * template_directory

The directory where spork writes all its templates during C<spork -make>. 
Templates will only be written if this directory does not exist.
So to force templates to be upgraded, delete this directory.

This directory should be listed in C<template_path>.

=item * template_path

A list of template directories to be used by the template processing class.

=back

=cut

__config.yaml__
################################################################################
# Spork Configuration File.
# 
# Please read this file over and set the values to your own.
#
# If you want global settings for all your slideshows, copy this file to
# ~/.sporkrc/config.yaml. Any settings in this local file will override
# the global value of that setting.
# 
# See C<perldoc Spork::Config> for details on settings.
################################################################################
author_name: Brian Ingerson
author_email: ingy@cpan.org
author_webpage: http://search.cpan.org/~ingy/
copyright_string: Copyright &copy; 2004 Brian Ingerson

banner_bgcolor: hotpink
show_controls: 1
mouse_controls: 1
image_width: 350
auto_scrolldown: 1
logo_image: logo.png
file_base: /Users/ingy/dev/cpan/Spork/

slides_file: Spork.slides
template_directory: template/tt2
template_path: 
- ./template/tt2
slides_directory: slides
download_method: wget
character_encoding: utf-8
link_previous: &lt; &lt; Previous
link_next: Next &gt;&gt;
link_index: Index

start_command: open slides/start.html

template_class: Spork::Template::TT2
formatter_class: Spork::Formatter
