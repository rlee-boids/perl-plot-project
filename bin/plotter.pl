#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use JSON qw(decode_json);
use File::Slurp qw(read_file);
use FindBin;
use lib "$FindBin::Bin/../lib";

use Plot::Generator;

my ($input, $output, $title);

GetOptions(
    "input=s"  => \$input,
    "output=s" => \$output,
    "title=s"  => \$title,
) or die "Usage: plotter.pl --input data.json --output out.png [--title \"Plot Title\"]\n";

die "Missing --input"  unless $input;
die "Missing --output" unless $output;

# Expect JSON like:
# {
#   "x": [1,2,3,4],
#   "y": [10,20,15,30]
# }

my $json_text = read_file($input);
my $data = decode_json($json_text);

my $pg = Plot::Generator->new(
    title   => $title // "Generated Plot",
    x_label => $data->{x_label} // "X",
    y_label => $data->{y_label} // "Y",
);

$pg->generate(
    x      => $data->{x},
    y      => $data->{y},
    output => $output,
);

print "Plot written to $output\n";

