package Spork::Formatter;
use strict;
use warnings;
use Spoon::Formatter '-Base';

sub init {
    $self->hub->load_class('slides');
}

const top_class => 'Spork::Formatter::Top';
const all_phrases => 
  [qw(wafl_phrase asis strong em u tt hyper)];

sub formatter_classes {
    map { "Spork::Formatter::$_" } qw(
        WaflBlock WaflPhrase WaflParagraph
        Heading Paragraph Preformatted 
        Ulist Olist Item
        Table TableRow TableCell
        Asis Strong Emphasize Underline Inline HyperLink
    );
}

sub wafl_classes {
    map { "Spork::Formatter::$_" } qw(
        Image File
    )
};

################################################################################
package Spork::Formatter::Block;
use base 'Spoon::Formatter::Block';
const contains_phrases => Spork::Formatter->all_phrases;

################################################################################
package Spork::Formatter::Phrase;
use base 'Spoon::Formatter::Phrase';
const all_phrases => Spork::Formatter->all_phrases;

################################################################################
package Spork::Formatter::Top;
use base 'Spoon::Formatter::Unit';
const formatter_id => 'top';
const contains_blocks => 
      [qw(wafl_block wafl_p heading ul ol pre p)];

################################################################################
package Spork::Formatter::WaflBlock;
use base 'Spoon::Formatter::WaflBlock';

################################################################################
package Spork::Formatter::Heading;
use base 'Spork::Formatter::Block';
const formatter_id => 'heading';
field 'level'; 

sub match {
    return unless $self->text =~ /^(={1,6})\s+(.*?)(\s+=+)?\s*\n+/m;
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
use base 'Spork::Formatter::Block';
const formatter_id => 'p';
const pattern_block => qr/((?:^[^\=\#\*\0\|\s].*\n|^[\*\/]+\S.*\n)+)/m;
const html_start => "<p>\n";
const html_end => "</p>\n";

################################################################################
package Spork::Formatter::WaflParagraph;
use base 'Spork::Formatter::Paragraph';
const formatter_id => 'wafl_p';
const pattern_block => qr/^(\{.*\})\n/m;
const html_start => "";
const html_end => "";
const text_filter => "";

################################################################################
package Spork::Formatter::List;
use base 'Spoon::Formatter::Block';
const contains_blocks => [qw(li)];
field 'level';
field 'start_level';
field 'tag_stack' => [];

sub match {
    my $bullet = $self->bullet;
    return unless 
      $self->text =~ /((?:^($bullet).*\n)(?:^\2(?!$bullet).*\n)*)/m;
    $self->set_match;
    ($bullet = $2) =~ s/\s//g;
    $self->level(length($bullet));
    return 1;
}

sub html_start {
    my $next = $self->next_unit;
    my $tag_stack = $self->tag_stack;
    $next->tag_stack($tag_stack)
      if ref($next) and $next->isa('Spork::Formatter::List');
    my $level = defined $self->start_level
      ? $self->start_level : $self->level;
    push @$tag_stack, ($self->html_end_tag) x $level;
    return ($self->html_start_tag x $level) . "\n";
}

sub html_end {
    my $level = $self->level;
    my $tag_stack = $self->tag_stack;
    my $next = $self->next_unit;
    my $newline = "\n";
    if (ref($next) and $next->isa('Spork::Formatter::List')) {
        my $next_level = $next->level;
        if ($level < $next_level) {
            $next->start_level($next_level - $level);
            $level = 0;
        }
        else {
            $next->start_level(0);
            $level = $level - $next_level;
            $newline = '';
        }
        if ($self->level - $level == $next->level and
            $self->formatter_id ne $next->formatter_id
           ) {
            $level++;
            $next->start_level($next->start_level + 1);
        }
    }
    return join('', reverse splice(@$tag_stack, 0 - $level, $level))
      . $newline;
}

################################################################################
package Spork::Formatter::Ulist;
use base 'Spork::Formatter::List';
const formatter_id => 'ul';
const html_start_tag => '<ul>';
const html_end_tag => '</ul>';
const bullet => '\*+\ +';

################################################################################
package Spork::Formatter::Olist;
use base 'Spork::Formatter::List';
const formatter_id => 'ol';
const html_start_tag => '<ol>';
const html_end_tag => '</ol>';
const bullet => '0+\ +';

################################################################################
package Spork::Formatter::Item;
use base 'Spork::Formatter::Block';
const formatter_id => 'li';
const html_start => "<li>";
const html_end => "</li>\n";
const bullet => '[0\*]+\ +';

sub match {
    my $bullet = $self->bullet;
    return unless 
      $self->text =~ /^$bullet(.*)\n/m;
    $self->set_match;
}

################################################################################
package Spork::Formatter::Preformatted;
use base 'Spoon::Formatter::Block';
const formatter_id => 'pre';
const html_start => "<pre>";
const html_end => "</pre>\n";

sub match {
    return unless $self->text =~ /((?:^ +\S.*?\n|^\n)+)/m;
    my $text = $1;
    $self->set_match;
    return unless $text =~ /\S/;
    return 1;
}

sub text_filter {
    my $text = shift;
    $text =~ s/(?<=\n)\s*$//mg;
    my $indent;
    for ($text =~ /^( +)/gm) {
        $indent = length()
          if not defined $indent or
             length() < $indent;
    }
    $text =~ s/^ {$indent}//gm;
    $text;
}

################################################################################
package Spork::Formatter::Table;
use base 'Spoon::Formatter::Block';
const formatter_id => 'table';
const contains_blocks => [qw(tr)];
const pattern_block => qr/((^\|.*?\|\n)+)/sm;
const html_start => "<table>\n";
const html_end => "</table>\n";

################################################################################
package Spork::Formatter::TableRow;
use base 'Spoon::Formatter::Block';
const formatter_id => 'tr';
const contains_blocks => [qw(td)];
const pattern_block => qr/(^\|.*?\|\n)/sm;
const html_start => "<tr>\n";
const html_end => "</tr>\n";

################################################################################
package Spork::Formatter::TableCell;
use base 'Spork::Formatter::Block';
const formatter_id => 'td';
field contains_blocks => [];
field contains_phrases => [];
const table_blocks => [qw(pre heading ol1 ul1 hr)];
const table_phrases => Spork::Formatter->all_phrases;
const html_start => "<td>";
const html_end => "</td>\n";

sub match {
    return unless $self->text =~ /(\|(\s*.*?\s*)\|)(.*)/sm;
    $self->start_offset($-[1]);
    $self->end_offset($3 eq "\n" ? $+[3] : $+[2]);
    my $text = $2;
    $text =~ s/^[ \t]*\n?(.*?)[ \t]*$/$1/;
    $self->text($text);
    if ($text =~ /\n/) {
        $self->contains_blocks($self->table_blocks);
    }
    else {
        $self->contains_phrases($self->table_phrases);
    }
    return 1;
}

################################################################################
# Phrase Classes
################################################################################
package Spork::Formatter::Strong;
use base 'Spork::Formatter::Phrase';
use Spork ':char_classes';
const formatter_id => 'strong';
const pattern_start => qr/(^|(?<=[^$ALPHANUM]))\*(?=\S)/;
const pattern_end => qr/\*(?=[^$ALPHANUM]|\z)/;
const html_start => "<strong>";
const html_end => "</strong>";

################################################################################
package Spork::Formatter::Emphasize;
use base 'Spork::Formatter::Phrase';
use Spork ':char_classes';
const formatter_id => 'em';
const pattern_start => qr/(^|(?<=[^$ALPHANUM]))\/(?=\S[^\/]*\/(?=\W|\z))/;
const pattern_end => qr/\/(?=[^$ALPHANUM]|\z)/;
const html_start => "<em>";
const html_end => "</em>";

################################################################################
package Spork::Formatter::Underline;
use base 'Spork::Formatter::Phrase';
use Spork ':char_classes';
const formatter_id => 'u';
const pattern_start => qr/(^|(?<=[^$ALPHANUM]))_(?=\S)/;
const pattern_end => qr/_(?=[^$ALPHANUM]|\z)/;
const html_start => "<u>";
const html_end => "</u>";

################################################################################
package Spork::Formatter::Inline;
use base 'Spoon::Formatter::Token';
use Spork ':char_classes';
const formatter_id => 'tt';
const contains_phrases => [];
const pattern_start => qr/(^|(?<=[^$ALPHANUM]))\|/;
const pattern_end => qr/\|(?=[^$ALPHANUM]|\z)/;
const html_start => "<tt>";
const html_end => "</tt>";

################################################################################
package Spork::Formatter::HyperLink;
use base 'Spoon::Formatter::Token';
const formatter_id => 'hyper';
our $pattern = qr/(?:https?|ftp)\:\/\/\S+/;
const pattern_start => qr/$pattern|!$pattern/;

sub html {
    my $text = $self->escape_html($self->matched);
    return $text if $text =~ s/^!//;
    return qq(<img src="$text" />)
      if $text =~ /^https?:\/\/.*(?i:jpe?g|gif|png)$/;
    return qq(<a href="$text">$text</a>);
}

################################################################################
package Spork::Formatter::Asis;
use base 'Spoon::Formatter::Token';
const formatter_id => 'asis';
const pattern_start => qr/\{\{/;
const pattern_end => qr/\}\}/;

################################################################################
package Spork::Formatter::WaflPhrase;
use base 'Spoon::Formatter::WaflPhrase';

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
}

1;
