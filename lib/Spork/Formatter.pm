package Spork::Formatter;
use strict;
use warnings;
use Spoon::Formatter '-Base';

const top_class => 'Spork::Formatter::Top';

sub formatter_classes {
    map { "Spork::Formatter::$_" } qw(
        Header Paragraph Preformatted
        Ulist1 Ulist2 Ulist3 Ulist4
        Olist1 Olist2 Olist3 Olist4
        Item1 Item2 Item3 Item4
        Bold Italic Underline Inline 
        HyperLink File Image
    );
}

################################################################################
package Spork::Formatter::Top;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'top';
const contains_blocks => [qw(header p ul1 ol1 pre)];

################################################################################
package Spork::Formatter::Header;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'header';
const contains_phrases => [qw(b i u tt)];
field 'level'; 

sub match {
    return unless $self->text =~ /^(={1,6}) (.*?)=*\s*\n+/m;
    $self->level(length($1));
    $self->set_match($2);
}

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
package Spork::Formatter::Paragraph;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'p';
const contains_phrases => [qw(b i u tt hyper file image)];
const html_start => "<p>\n";
const html_end => "</p>\n";

sub match {
    return unless $self->text =~ /((?:^[^\=\#\*\0\s].*\n)+)/m;
    $self->set_match;
}

################################################################################
package Spork::Formatter::Ulist;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'ul';
const html_start => "<ul>\n";
const html_end => "</ul>\n";
const level => 1;

sub match {
    my $level = $self->level;
    return unless 
      $self->text =~ /((?:^\*{$level} .*\n)(?:^[*0 ]{$level,} .*\n)*)/m;
    $self->set_match;
}

################################################################################
for my $level (1..4) {
    my $list = join ' ', $level != 4 
    ? ("ul" . ($level + 1), "ol" . ($level + 1), "li$level")
    : ("li$level");
    eval <<END; die $@ if $@;
package Spork::Formatter::Ulist$level;
use base 'Spork::Formatter::Ulist';
const formatter_id => 'ul$level';
const level => $level;
const contains_blocks => [qw($list)];
END
}

################################################################################
package Spork::Formatter::Olist;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'ol';
field html_start => "<ol>\n";
field html_end => "</ol>\n";

sub match {
    my $level = $self->level;
    return unless 
      $self->text =~ /((?:^0{$level} .*\n)(?:^[\*0 ]{$level,} .*\n)*)/m;
    $self->set_match;
}

################################################################################
for my $level (1..4) {
    my $list = join ' ', $level != 4 
    ? ("ol" . ($level + 1), "ul" . ($level + 1), "li$level")
    : ("li$level");
    eval <<END; die $@ if $@;
package Spork::Formatter::Olist$level;
use base 'Spork::Formatter::Olist';
const formatter_id => 'ol$level';
const level => $level;
const contains_blocks => [qw($list)];
END
}

################################################################################
package Spork::Formatter::Item;
use base 'Spoon::Formatter::Unit';
const html_start => "<li>";
const html_end => "</li>\n";
const contains_phrases => [qw(hyper b i u tt hyper file image)];

sub match {
    my $level = $self->level;
    return unless 
      $self->text =~ /^[0\*]{$level} +(.*)\n/m;
    $self->set_match;
}

################################################################################
for my $level (1..4) {
    eval <<END; die $@ if $@;
package Spork::Formatter::Item$level;
use base 'Spork::Formatter::Item';
const formatter_id => 'li$level';
const level => $level;
END
}

################################################################################
package Spork::Formatter::Preformatted;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'pre';

sub match {
    return unless $self->text =~ /((?:^ +\S.*?\n|^\n)+)/m;
    my ($text, $start, $end) = ($1, $-[0], $+[0]);
    return unless $text =~ /\S/;
    $self->set_match($text, $start, $end);
}

sub to_html {
    my $formatted = join '', map {
        my $text = $_;
        $text =~ s/(?<=\n)\s*$//;
        my $indent;
        for ($text =~ /^( +)/gm) {
            $indent = length()
              if not defined $indent or
                 length() < $indent;
        }
        $text =~ s/^ {$indent}//gm;
        $self->escape_html($text);
    } @{$self->units};
    qq{<blockquote>\n<pre style="font-size:13">$formatted</pre>\n</blockquote>\n};
}

################################################################################
# Phrase Classes
################################################################################
package Spork::Formatter::Bold;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'b';
const html_start => "<b>";
const html_end => "</b>";
# const contains_phrases => [qw(i u tt href mail wiki)];
const contains_phrases => [qw(i u tt)]; #XXX
const pattern_start => qr/(^|(?<=\s))\*(?=\S)/;
const pattern_end => qr/\*(?=\W|\z)/;

################################################################################
package Spork::Formatter::Italic;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'i';
const html_start => "<i>";
const html_end => "</i>";
const contains_phrases => [qw(b u tt)];
const pattern_start => qr/(^|(?<=\s))\/(?=\S)/;
const pattern_end => qr/\/(?=\W|\z)/;

################################################################################
package Spork::Formatter::Underline;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'u';
const html_start => "<u>";
const html_end => "</u>";
# const contains_phrases => [qw(b u tt href mail wiki)];
const contains_phrases => [qw(b i tt)]; #XXX
const pattern_start => qr/(^|(?<=\s))_(?=\S)/;
const pattern_end => qr/_(?=\W|\z)/;

################################################################################
package Spork::Formatter::Inline;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'tt';
const html_start => qq{<tt style="font-size:13">};
const html_end => "</tt>";
const pattern_start => qr/(^|(?<=\s))\|(?=\S)/;
const pattern_end => qr/(?!<\\)\|(?=\W|\z)/;

################################################################################
package Spork::Formatter::HyperLink;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'hyper';
const pattern_start => qr/http:\/\/\S+/;

sub html_start {
    '<a href="' . $self->matched . 
    '" target="external" style="text-decoration:underline">' . 
    $self->matched . '</a>';
}

################################################################################
package Spork::Formatter::File;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'file';
const pattern_start => qr/(^|(?<=\s))file</;
const pattern_end => qr/>/;
field 'link_file';
field 'link_text';

sub text_filter {
    my $text = shift;
    $text =~ s/(.*?)(?:\s+|\z)//;
    $self->link_file($1);
    $self->link_text($text || $self->link_file);
    return '';
}

sub html_start {
    require Cwd;
    my $file = $self->link_file;
    $file = $self->hub->config->file_base . "/$file"
      unless $file =~ /^\.{0,1}\//;
    $file = Cwd::abs_path($file);
    qq{<a href="file://$file" } . 
      'target="file" style="text-decoration:underline">' . 
      $self->link_text . '</a>';
}

################################################################################
package Spork::Formatter::Image;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'image';
const pattern_start => qr/(^|(?<=\s))image</;
const pattern_end => qr/>/;

sub to_html {
    $self->hub->slides->image_url($self->units->[0]);
    return '';
}

1;
