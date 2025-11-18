#!/usr/bin/env perl
use strict;
use warnings;

use GD::Graph::lines;

# Sample X and Y data
my @x = (1, 2, 3, 4, 5);
my @y = (2, 3, 5, 4, 6);

my @data = (\@x, \@y);

# Create a new line graph object (width x height)
my $graph = GD::Graph::lines->new(600, 400);

# Set some basic options
$graph->set(
    x_label           => 'X',
    y_label           => 'Y',
    title             => 'Simple Perl Line Plot',
    y_max_value       => 7,
    y_min_value       => 0,
    y_tick_number     => 7,
    y_label_skip      => 1,
    line_width        => 2,
    transparent       => 0,
) or die $graph->error;

# Plot the data
my $gd_image = $graph->plot(\@data) 
    or die $graph->error;

# Write to a PNG file
open my $out, '>', 'output.png' or die "Cannot open output.png: $!";
binmode $out;
print $out $gd_image->png;
close $out;

print "Plot saved to output.png\n";
