package Spork;
use strict;
use warnings;
our $VERSION = '0.16';
use Spoon 0.13 '-base';

const config_class => 'Spork::Config';

1;

__END__

=head1 NAME

Spork - Slide Presentations (Only Really Kwiki)

=head1 SYNOPSIS

    mkdir my-slideshow
    cd my-slideshow
    spork -new
    vim Spork.slides
    vim config.yaml
    spork -make
    spork -start

=head1 DESCRIPTION

Spork lets you create HTML slideshow presentations easily. It comes with a
sample slideshow. All you need is a text editor, a browser and a topic.

Spork allows you create an entire slideshow by editing a single file called
C<Spork.slides> (by default). Each slide is created using a minimal markup
language similar to the syntax used in Kwiki wikis.

=head1 MARKUP SYNTAX

B<NOTE>: The current syntax has changed in a non-backwards-compatible way
as of release 0.16. This was done to keep pace with current Kwiki
formatting rules. The main change is the markup for images. Please
update old slideshows accordingly.

=head2 Slides

Slides are separated by lines consisting entirely of four or more
dashes. Each slide consists of text and markup. This section describes
each of the markup units.

Any slide can be made to be multipart by putting a '+' at the beginning of a
line where you want to break it. Each subpart will be cumulative to that
point.

=head2 Headings

A heading is a line starting with 1-6 equals signs followed by a space
followed by the heading text. The number of equals signs corresponds to the
level of the heading.

    === A Level Three Heading

=head2 Paragraphs

Paragraphs are just paragraphs. They end with a blank line.

    This is my paragraph of something that I wanted to show
    you. This paragraph is now ending.

=head2 Preformatted Text

Preformatted text, like program source code for instance, is indicated by
indenting it.

    My code:
    
        sub greet {
            print "Hello there\n";
        }

=head2 Pretty Print

You can markup a section of your source code with various colors and
highlights. In this example we make the word "greet" display green and the
word "Hello" display red and underline the quoted string.

    .pretty.
        sub greet {
    #       GGGGG
            print "Hello there\n";
    #             _______________
    #              RRRRR
        }    
    .pretty.

Coming soon.

=head2 Unordered List

Use asterisks to mark bullet points. The number of asterisks indicates the
nesting level.

    * Point One
    ** Point One A
    ** Point One B
    * Point Two
    * Point Three

=head2 Ordered List

Same as unordered lists except use zeroes to mark bullet points. Ordered and
unordered lists can be intermingled.

    0 Point One
    ** Point One A
    ** Point One B
    0 Point Two
    0 Point Three

=head2 Bold Text

Sourround one or more words with asterisks to make the text bold.

    This is *bold text* example.

=head2 Italic Text

Sourround one or more words with slashes to make the text italicized.

    This is /italic text/ example.

=head2 Underlined Text

Sourround one or more words with underscores to make the text underlined.

    This is _underlined text_ example.

=head2 Teletyped Text

Sourround one or more words with pipes to make the text appear in a fixed
width font.

    This is |fixed width font| example.

=head2 Images

Each slide can display an image.

    {image: http://www.example.com/images/xyz123.png}

This will download a copy of the image if it hasn't been downloaded yet. That
way you can view your slides offline. 

If more than one image is encoded in a slide, Spork takes the last one. This
is useful for a multipart slide where you want the image to change. Just put
this image tag in the correct subpart.

=head2 Files

You can create a link to a local file. When clicked the file should appear in
a new browser window.

    {file: mydir/myfile.txt}

The C<file_base> configuration setting will be prepended to relative paths.

=head1 CONFIGURATION

Spork slideshows can be configured in three different ways. The first
way is with the local C<config.yaml> created by C<spork -new>. The
second way is through a global configuration file called
C<~/.sporkrc/config.yaml>. Any settings in the local file will override
settings in the global file.

The third way is to put YAML sections directly in your slides file. You
can put a YAML section anywhere in the file that a slide would go, and
you can have more than one section. In fact, you could change the
configuration for each slide by putting a YAML section before each
slide. Any settings in these sections will override the setting that
came from anywhere else.

See L<Spork::Config> for more information.

=head1 CUSTOMIZATION

You can easily extend and customize Spork by writing subclasses and putting
them in the configuration or by fiddling with the template files. This version
uses Template Toolkit templates by default. HTML::Mason support is being
developed by Dave Rolsky.

=head1 SEE ALSO

Kwiki, Spoon, Spork::Template::Mason

=head1 AUTHOR

Brian Ingerson <INGY@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
