use inc::Module::Install;

name('Spork');
author('Brian Ingerson <ingy@cpan.org>');
abstract('Slide Presentations (Only Really Kwiki)');
license('perl');
version_from('lib/Spork.pm');

requires(qw(
    perl 5.6.1
    Kwiki 0.37
));

clean_files('t/spork');
install_script('spork');

check_nmake();

&WriteAll();
