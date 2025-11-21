package Plot::Generator;
use strict;
use warnings;
use Carp qw(croak);
use GD::Graph::lines;

our $VERSION = '0.01';

=head1 NAME

Plot::Generator - Generate line plots (PNG) from numeric datasets

=head1 SYNOPSIS

  use Plot::Generator;
  my $pg = Plot::Generator->new(
      title => "CPU Usage Over Time",
      x_label => "Time",
      y_label => "CPU (%)",
  );

  $pg->generate(
      x => \@timestamps,
      y => \@cpu_values,
      output => "cpu.png"
  );

=head1 DESCRIPTION

This module provides a generic interface for creating
PNG line plots from two numerical arrays. It performs
basic validation, formatting, and rendering.

=cut

sub new {
    my ($class, %args) = @_;

    my $self = {
        title   => $args{title}   // '',
        x_label => $args{x_label} // 'X',
        y_label => $args{y_label} // 'Y',
        width   => $args{width}   // 800,
        height  => $args{height}  // 600,
    };

    return bless $self, $class;
}

sub generate {
    my ($self, %args) = @_;

    my $x = $args{x}       or croak "Missing required parameter: x";
    my $y = $args{y}       or croak "Missing required parameter: y";
    my $output = $args{output} or croak "Missing required parameter: output";

    croak "x and y must be ARRAYREFs"
        unless ref($x) eq 'ARRAY' && ref($y) eq 'ARRAY';

    croak "x and y must be same length"
        unless @$x == @$y;

    my @data = ($x, $y);

    my $graph = GD::Graph::lines->new($self->{width}, $self->{height});
    $graph->set(
        x_label => $self->{x_label},
        y_label => $self->{y_label},
        title   => $self->{title},
        line_width => 2,
        dclrs      => ["blue"],
    ) or croak $graph->error;

    my $gd = $graph->plot(\@data)
        or croak $graph->error;

    open(my $fh, '>', $output) or croak "Cannot open $output: $!";
    binmode $fh;
    print $fh $gd->png;
    close $fh;

    return $output;
}

1;

__END__

=head1 AUTHOR

Your Name <you@example.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2024.

=cut

