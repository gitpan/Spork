package Spork::Slides;
use strict;
use warnings;
use Spork '-base';
use Spoon::Utils '-base';
use IO::All;

field const class_id => 'slides';
field image_url => '';
field slide_heading => '';
field slide_index => [];
field 'first_slide';

sub init {
    my $self = shift;
    $self->use_class('config');
}

sub copy_files {
    my $self = shift;
    my $input_dir = $self->config->template_directory;
    my $output_dir = $self->config->slides_directory;
    $self->assert_directory($output_dir);
    io("$input_dir/slide.css") > io("$output_dir/slide.css");
}

sub make_slides {
    my $self = shift;
    $self->use_class('formatter');
    $self->use_class('template');
    
    $self->remove_tree($self->config->slides_directory);
    $self->assert_directory($self->config->slides_directory);
    my @slides = $self->split_slides($self->config->slides_file);
    $self->first_slide($slides[0]);
    for (my $i = 0; $i < @slides; $i++) {
        my $slide = $slides[$i];
        my $content = $slides[$i]{slide_content};
        $slide->{first_slide} = $slide->{slide_name};
        $slide->{prev_slide} = $i ? $slides[$i - 1]{slide_name} : '';
        $slide->{next_slide} = $slides[$i + 1]  
          ? $slides[$i + 1]{slide_name} : '';
        $self->slide_heading('');
        $self->image_url('');
        my $parsed = $self->formatter->text_to_parsed($content);
        my $html = $parsed->to_html;
        $slide->{slide_heading} = $self->slide_heading;
        $slide->{image_html} = $self->get_image_html;
        my $output = $self->template->process('slide.html',
            %$slide,
            index_slide => 'index.html',
            slide_content => $html,
            spork_version => "Spork v$Spork::VERSION",
        );
        my $file_name = $self->config->slides_directory . '/' . 
                        $slide->{slide_name};
        $output > io($file_name);
        push @{$self->slide_index}, $slide
          if $slide->{slide_name} =~ /^slide\d+a?\.html$/;
    }
    $self->make_index;
    $self->make_start;
}

sub make_index {
    my $self = shift;
    my $output = $self->template->process('index.html',
        slides => $self->slide_index,
        spork_version => "Spork v$Spork::VERSION",
        next_slide => $self->first_slide->{slide_name},
    );
    my $file_name = $self->config->slides_directory . '/index.html';
    $output > io($file_name);
}

sub make_start {
    my $self = shift;
    my $output = $self->template->process('start.html',
        spork_version => "Spork v$Spork::VERSION",
        index_slide => 'index.html',
        next_slide => $self->first_slide->{slide_name},
    );
    my $file_name = $self->config->slides_directory . '/start.html';
    $output > io($file_name);
}

sub split_slides {
    my $self = shift;
    my $slides_file = shift;
    my @slide_info;
    my @slides = grep $_, split /^-{4,}\s*\n/m, io($slides_file)->slurp;
    my $slide_num = 1;
    for my $slide (@slides) {
        my @sub_slides = $self->sub_slides($slide);
        my $sub_num = @sub_slides > 1 ? 'a' : '';
        while (@sub_slides) {
            my $sub_slide = shift @sub_slides;
            my $slide_info = {
                slide_num => $slide_num,
                slide_content => $sub_slide,
                slide_name => "slide$slide_num$sub_num.html",
                last => @sub_slides ? 0 : 1,
            };
            push @slide_info, $slide_info;
            $sub_num++;
        }
        $slide_num++;
    }
    return @slide_info;
}

sub sub_slides {
    my $self = shift;
    my $raw_slide = shift;
    my (@slides, $slide);
    for (split /^\+/m, $raw_slide) {
        push @slides, $slide .= $_;
    }
    return @slides;
}

sub get_image_html {
    my $self = shift;
    my $image_url = $self->image_url
      or return '';
    my $image_file = $image_url;
    $image_file =~ s/.*\///;
    my $images_directory = $self->config->slides_directory . '/images';
    $self->assert_directory($images_directory);
    my $image_html =
      qq{<img name="img" id="img" src="images/$image_file" align=right>};
    return $image_html if -f "$images_directory/$image_file";
    require Cwd;
    my $home = Cwd::cwd();
    chdir($images_directory) or die;
    system "wget $image_url 2> .wget-output";
    chdir($home) or die;
    return -f "$images_directory/$image_file" ? $image_html : '';
}

1;
