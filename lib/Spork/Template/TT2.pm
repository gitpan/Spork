package Spork::Template::TT2;
use strict;
use warnings;
use Spoon::Template::TT2 '-base';
use Spoon::Installer '-base';

sub plugins { {} }

sub extract_to {
    my $self = shift;
    $self->hub->config->template_directory;
}

sub include_path {
    my $self = shift;
    $self->hub->config->template_path || 
      [ $self->hub->config->template_directory ];
}

1;
__DATA__
__top.html__
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<!-- BEGIN top.html -->
<html>
<head>
<title>[% slide_heading %]</title>
<meta name="Content-Type" content="text/html; charset=[% character_encoding %]">
<meta name="generator" content="[% spork_version %]">
<link rel='icon' HREF='favicon.png'>
<style><!--
[% INCLUDE slide.css %]
--></style>
<script>
[% INCLUDE controls.js %]
</script>
</head>
<body bgcolor="#ffffff" background="[% background_image %]">
<div id="topbar">
<table width='100%'>
<tr>
<td width="13%">[% presentation_topic %]</td>
<td align=center width="73%">
    <a accesskey="s" href="start.html">[% presentation_title %]</a>
</td>
<td align=right width="13%">
    [% slide_num ? "#$slide_num" : '&nbsp;' %]
</td>
</tr>
</table>
</div>
<!-- END top.html -->
__bottom.html__
<!-- BEGIN bottom.html -->
<div id="bottombar">
<table width="100%">
<tr>
<td align="left" valign="middle">
    <div[% show_controls ? '' : ' style="display:none"' %]>
    <a accesskey='p' href="[% prev_slide %]">[% link_previous %]</a> |
    <a accesskey='i' href="[% index_slide %]">[% link_index %]</a> |
    <a accesskey='n' href="[% next_slide %]">[% link_next %]</a>
    </div>
</td>
<td align="right" valign="middle">
    [% copyright_string %]
</td>
</tr>
</table>
</div> 
<a name="end"></a>
<div id="logo"></div>
<div id="spacer"></div>
</body>
</html>
<!-- END bottom.html -->
__index.html__
<!-- BEGIN index.html -->
[% INCLUDE top.html %]
<div id="content"><P>
<ol>
[% FOR slide = slides -%]
<li> <a href="[% slide.slide_name %]">[% slide.slide_heading %]</a>
[% END -%]
</ol>
</div>
[% INCLUDE bottom.html %]
<!-- END index.html -->
__start.html__
<!-- BEGIN start.html -->
[% INCLUDE top.html %]
<div id="content"><P>
<center>
<h4>[% presentation_title %]</h4>
<p />
<h4>[% author_name %]</h4>
<h4>[% author_email %]</h4>
<p />
<h4>[% presentation_place %]</h4>
<h4>[% presentation_date %]</h4>
</center>
</div>
[% INCLUDE bottom.html %]
<!-- END start.html -->
__slide.html__
<!-- BEGIN slide.html -->
[% INCLUDE top.html %]
<div id="content"><P>
[% image_html %]
[% slide_content -%]
[%- UNLESS last -%]
<small>continued...</small>
[% END %]
</div>
[% INCLUDE BOTTOM.html %]
<!-- END slide.html -->
__slide.css__
/* BEGIN index.css */
hr {
    color: #202040;
    height: 0px;
    border-top: 0px;
    border-bottom: 3px #202040 ridge;
    border-left: 0px;
    border-right: 0px;
}

a:link {
    color: #123422;
    text-decoration: none;
}

a:visited {
    color: #123333;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

p {
    font-size: 24pt;
    margin: 6pt;
}

div p {
    font-size: 18pt;
    margin-top: 12pt;
    margin-bottom: 12pt;
    margin-left: 6pt;
    margin-right: 6pt;
}

small {
    font-size: 9pt;
    font-style: italic;
}

#topbar {
    background: [% banner_bgcolor %];
    color: blue;
    position:absolute;
    right: 5px;
    left: 5px;
    top: 5px;
    height: 50px;
}

#bottombar {
    background: [% banner_bgcolor %];
    color: blue;
    position: fixed;
    right: 5px;
    left: 5px;
    bottom: 5px;
    height: 50px;
    z-index: 0;
}

#spacer {
    bottom: 5px;
    height: 50px;
}

#content {
    background:#fff;
    margin-left: 20px;
    margin-right:20px;
    margin-top: 80px;
}


#logo {
    position: fixed;
    right: 40px;
    bottom: 51px;
    width: 130px;
    height: 150px;
    z-index:3;
    background-image: url([% images_directory %]/[% logo_image %]);
    background-repeat: no-repeat;
}
/* END index.css */
__controls.js__
// BEGIN controls.js
function nextSlide() {
    window.location = '[% next_slide %]';
}

function prevSlide() {
    window.location = '[% prev_slide %]';
}

function indexSlide() {
    window.location = 'index.html';
}

function startSlide() {
    window.location = 'start.html';
}

function closeSlide() {
    window.close();
}

function handleKey(e) {
    var key;
    if (e == null) {
        // IE
        key = event.keyCode
    } 
    else {
        // Mozilla
        if (e.altKey || e.ctrlKey) {
            return true
        }
        key = e.which
    }
    switch(key) {
        case 8: prevSlide(); break
        case 13: nextSlide(); break
        case 32: nextSlide(); break
        case 81: closeSlide(); break
        case 105: indexSlide(); break
        case 110: nextSlide(); break
        case 112: prevSlide(); break
        case 115: startSlide(); break
        default: //xxx(e.which)
    }
}

document.onkeypress = handleKey
document.onclick = nextSlide
// END controls.js
