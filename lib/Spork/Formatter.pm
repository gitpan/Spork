package Spork::Formatter;
use strict;
use Spoon::Formatter '-base';
use constant LIST_MAX => 7;

field const top_class => 'Spork::Formatter::Top';

sub register {
    my $self = shift;
    $self->register(formatter => 'Spork::Formatter::Line');
    $self->register(formatter => 'Spork::Formatter::Header');
    # etc
}

# XXX This table method is just temporary until the above registry works
sub table {             
    my $self = shift;
    $self->{table} ||= do {
        my %table = map {
            my $class = "Spork::Formatter::$_";
            $class->can('formatter_id') ? ($class->formatter_id, $class) : ();
        } qw(
            Line Header Paragraph Preformatted Table Comment Image
            Ulist1 Ulist2 Ulist3 Ulist4 Ulist5 Ulist6 Ulist7
            Olist1 Olist2 Olist3 Olist4 Olist5 Olist6 Olist7
            Item1 Item2 Item3 Item4 Item5 Item6 Item7
            Bold Italic Underline Inline
        );
        \ %table;
    };
}

################################################################################
package Spork::Formatter::Top;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'top';
field const html_start => '';
field const html_end => '';
field const contains_blocks => [qw(hr img header p ul1 ol1 pre table)];

################################################################################
package Spork::Formatter::Image;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'img';
field 'url';

sub match {
    my $self = shift;
    return unless $self->text =~ /^<\s*(.*)\s*>\n/m;
    $self->set_match;
}

sub to_html {
    my $self = shift;
    $self->hub->slides->image_url($self->units->[0]);
    return '';
}

################################################################################
package Spork::Formatter::Line;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'hr';
field const html_start => "<hr />\n";
field const html_end => '';

sub match {
    my $self = shift;
    return unless $self->text =~ /^----+\s*\n/m;
    $self->set_match;
}

################################################################################
package Spork::Formatter::Header;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'header';
# field const contains_phrases => [qw(b i u tt href mail wiki)];
field const contains_phrases => [qw(b i)]; #XXX
field 'level'; 

sub to_html {
    my $self = shift;
    my $text = $self->units->[0];
    my $level = $self->level;
    $self->hub->slides->slide_heading($text)
      unless $self->hub->slides->slide_heading;
    return "<h$level>$text</h$level>\n";
}

sub match {
    my $self = shift;
    return unless $self->text =~ /^(={1,6}) (.*?)=*\s*\n+/m;
    $self->level(length($1));
    $self->set_match($2);
}

################################################################################
package Spork::Formatter::Paragraph;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'p';
field const html_start => "<p>\n";
field const html_end => "</p>\n";
# field const contains_phrases => [qw(b i u tt href mail wiki)];
field const contains_phrases => [qw(b i u tt)]; #XXX

sub match {
    my $self = shift;
    return unless $self->text =~ /((?:^[^\=\#\*\0\s].*\n)+)/m;
    $self->set_match;
}

################################################################################
package Spork::Formatter::Ulist;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'ul';
field const html_start => "<ul>\n";
field const html_end => "</ul>\n";
field const level => 1;

sub match {
    my $self = shift;
    my $level = $self->level;
    return unless 
      $self->text =~ /((?:^\*{$level} .*\n)(?:^[*0 ]{$level,} .*\n)*)/m;
    $self->set_match;
}

################################################################################
for my $level (1..Spork::Formatter::LIST_MAX) {
    my $list = join ' ', $level != Spork::Formatter::LIST_MAX 
    ? ("ul" . ($level + 1), "ol" . ($level + 1), "li$level")
    : ("li$level");
    eval <<END; die $@ if $@;
package Spork::Formatter::Ulist$level;
use base 'Spork::Formatter::Ulist';
field const formatter_id => 'ul$level';
field const level => $level;
field const contains_blocks => [qw($list)];
END
}

################################################################################
package Spork::Formatter::Olist;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'ol';
field html_start => "<ol>\n";
field html_end => "</ol>\n";

sub match {
    my $self = shift;
    my $level = $self->level;
    return unless 
      $self->text =~ /((?:^0{$level} .*\n)(?:^[\*0 ]{$level,} .*\n)*)/m;
    $self->set_match;
}

################################################################################
for my $level (1..Spork::Formatter::LIST_MAX) {
    my $list = join ' ', $level != Spork::Formatter::LIST_MAX 
    ? ("ol" . ($level + 1), "ul" . ($level + 1), "li$level")
    : ("li$level");
    eval <<END; die $@ if $@;
package Spork::Formatter::Olist$level;
use base 'Spork::Formatter::Olist';
field const formatter_id => 'ol$level';
field const level => $level;
field const contains_blocks => [qw($list)];
END
}

################################################################################
package Spork::Formatter::Item;
use base 'Spoon::Formatter::Unit';
field const html_start => "<li>";
field const html_end => "</li>\n";
field const contains_phrases => [qw(b i u tt)];

sub match {
    my $self = shift;
    my $level = $self->level;
    return unless 
      $self->text =~ /^[0\*]{$level} +(.*)\n/m;
    $self->set_match;
}

################################################################################
for my $level (1..Spork::Formatter::LIST_MAX) {
    eval <<END; die $@ if $@;
package Spork::Formatter::Item$level;
use base 'Spork::Formatter::Item';
field const formatter_id => 'li$level';
field const level => $level;
END
}

################################################################################
package Spork::Formatter::Preformatted;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'pre';

sub match {
    my $self = shift;
    return unless $self->text =~ /((?:^ +\S.*?\n|^\n)+)/m;
    my ($text, $start, $end) = ($1, $-[0], $+[0]);
    return unless $text =~ /\S/;
    $self->set_match($text, $start, $end);
}

sub to_html {
    my $self = shift;
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
    "<blockquote>\n<pre>$formatted</pre>\n</blockquote>\n";
}

################################################################################
package Spork::Formatter::Table;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'table';
field const html_start => '<p>';
field const html_end => '</p>';

sub match {
    my $self = shift;
    return unless $self->text =~ /^<####>/m;
    $self->set_match;
}

################################################################################
# Phrase Classes
################################################################################
package Spork::Formatter::Bold;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'b';
field const html_start => "<b>";
field const html_end => "</b>";
# field const contains_phrases => [qw(i u tt href mail wiki)];
field const contains_phrases => [qw(i u tt)]; #XXX
field const pattern_start => qr/(^|(?<=\s))\*(?=\S)/;
field const pattern_end => qr/\*(?=\W|\z)/;

################################################################################
package Spork::Formatter::Italic;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'i';
field const html_start => "<i>";
field const html_end => "</i>";
# field const contains_phrases => [qw(b u tt href mail wiki)];
field const contains_phrases => [qw(b u tt)]; #XXX
field const pattern_start => qr/(^|(?<=\s))\/(?=\S)/;
field const pattern_end => qr/\/(?=\W|\z)/;

################################################################################
package Spork::Formatter::Underline;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'u';
field const html_start => "<u>";
field const html_end => "</u>";
# field const contains_phrases => [qw(b u tt href mail wiki)];
field const contains_phrases => [qw(b i tt)]; #XXX
field const pattern_start => qr/(^|(?<=\s))_(?=\S)/;
field const pattern_end => qr/_(?=\W|\z)/;

################################################################################
package Spork::Formatter::Inline;
use base 'Spoon::Formatter::Unit';
field const formatter_id => 'tt';
field const html_start => "<tt>";
field const html_end => "</tt>";
field const contains_phrases => [];
field const pattern_start => qr/(^|(?<=\s))\|(?=\S)/;
field const pattern_end => qr/\|(?=\W|\z)/;

1;
