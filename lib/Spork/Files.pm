package Spork::Files;
use strict;
use Spoon::Installer '-base';

1;
__DATA__
__Spork.slides__
== What is Spork?
* Spork Stands for:
+** Slide Presentation (Only Really Kwiki)
+* Spork is an HTML Slideshow Generator
+* Spork is a CPAN Module
+* Spork is Based on Spoon
----
== Installing The Spork Module
* |perl Makefile.PL|
* |make|
* |make test|
* |make install|
----
== Using Spork

Spork makes setting up a slide presentation very easy. Just follow these easy
steps:

* mkdir myslides
* cd myslides
* spork -new
* vim config.yaml Spork.slides
* spork -make
* spork -start
----
== Creating Slides
Slides are all done in *Kwiki* markup language. Simple stuff.

* Example Slide:

    == Sample Slide
    My point is, it's as easy as:
    * One
    +* Two
    +* Three

Putting a plus (+) at the start of a line creates a subslide effect.
----
== Using Images
* Hey Look. A picture!
<http://search.cpan.org/s/img/cpan_banner.png>
+* Woah, it changed!
<http://cpan.org/misc/jpg/cpan.jpg>
+* Images are cached locally
----
== That's All

* The END
__template/top.html__
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
<head>
<title>[% slide_heading %]</title>
<meta name="Content-Type" content="text/html; charset=utf-8">
<meta name="generator" content="[% spork_version %]">
<link rel='stylesheet' href='slide.css' type='text/css'>
<link rel='icon' HREF='favicon.png'>
</head>
<body bgcolor="#ffffff" background="[% background_image %]">
<div id="topbar">
<table width='100%'>
    <tr>
        <td width=13%>[% presentation_topic %]</td>
        <td align=center width=73%>
            <a href="[% index_slide %]">[% presentation_title %]</a>
        </td>
        <td align=right width=13%>#[% slide_num %]</td>
    </tr>
</table>
</div>
__template/bottom.html__
<div id="bottombar">
<table width="100%">
    <tr>
        <td align="left" valign="middle">
            <a href="[% prev_slide %]">&lt;&lt; Previous</a> |
            <a href="[% index_slide %]">Index</a> |
            <a href="[% next_slide %]">Next &gt;&gt;</a>
        </td>
        <td align="right" valign="middle">
            [% copyright_string %]
        </td>
    </tr>
</table>
</div> 
<div id="logo" />

</body>
</html>
__template/index.html__
[% INCLUDE top.html %]
<div id="content"><P>
<ol>
[% FOR slide = slides -%]
<li> <a href="[% slide.slide_name %]">[% slide.slide_heading %]</a>
[% END -%]
</ol>
</div>
[% INCLUDE bottom.html %]
__template/start.html__
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
__template/slide.html__
[% INCLUDE top.html %]
<div id="content"><P>
[% image_html %]
[% slide_content -%]
[%- UNLESS last -%]
<small>continued...</small>
[% END %]
</div>
[% INCLUDE bottom.html %]
__template/slide.css__
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
    background: hotpink;
    color: blue;
    position:absolute;
    right: 5px;
    left: 5px;
    top: 5px;
    height: 50px;
}

#bottombar {
    background: hotpink;
    color: blue;
    position: fixed;
    right: 5px;
    left: 5px;
    bottom: 5px;
    height: 50px;
    z-index: 0;
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
    background-image: url(beastie.png);
    background-repeat: no-repeat;
}
