use Cwd qw(abs_path);
use lib abs_path('t'), abs_path('lib');
use strict;
use warnings;
use Test::More tests => 3;
use Spork;
use File::Path;

my $spork_dir = 't/spork';
File::Path::rmtree($spork_dir);

$SIG{__WARN__} = sub { };

ok(mkdir($spork_dir));
chdir($spork_dir) or die;
Spork->new->load_hub->load_class('command')->process('-new');

ok(-f 'Spork.slides');

Spork->new->load_hub->load_class('command')->process('-make');

ok(-f 'slides/index.html');
