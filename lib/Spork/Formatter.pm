package Spork::Formatter;
use strict;
use warnings;
use Kwiki::Formatter '-Base';

sub init {
    $self->hub->load_class('slides');
}

sub formatter_classes {
    map { s/^Heading$/Spork::Formatter::Heading/; $_ } super;
}  

const all_phrases => [qw(wafl_phrase asis strong em u tt hyper)];

sub wafl_classes { qw( Spork::Formatter::Image Spork::Formatter::File) }

################################################################################
package Spork::Formatter::Heading;
use base 'Kwiki::Formatter::Heading';

sub to_html {
    my $text = join '', map {
        ref $_ ? $_->to_html : $_
    } @{$self->units};
    my $level = $self->level;
    $self->hub->slides->slide_heading($text)
      unless $self->hub->slides->slide_heading;
    return "<h$level>$text</h$level>\n";
}

################################################################################
package Spork::Formatter::File;
use base 'Spoon::Formatter::WaflPhrase';
const wafl_id => 'file';

sub html {
    require Cwd;
    my ($file, $link_text) = split /\s+/, $self->arguments, 2;
    $link_text ||= $file;
    $file = $self->hub->config->file_base . "/$file"
      unless $file =~ /^\.{0,1}\//;
    $file = Cwd::abs_path($file);
    qq{<a href="file://$file" } . 
      'target="file" style="text-decoration:underline">' . 
      $link_text . '</a>';
}

################################################################################
package Spork::Formatter::Image;
use base 'Spoon::Formatter::WaflPhrase';
const wafl_id => 'image';

sub to_html {
    $self->hub->slides->image_url($self->arguments);
    return '';
}

1;
