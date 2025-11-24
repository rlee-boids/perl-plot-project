package Plot::Generator;
use strict;
use warnings;
use Carp qw(croak);
use GD::Graph::lines;

our $VERSION = '0.02';

=head1 NAME

Plot::Generator - Generate line plots (PNG) from numeric datasets

=cut

sub new {
    my ($class, %args) = @_;

    my $self = {
        title         => $args{title}         // '',
        x_label       => $args{x_label}       // 'X',
        y_label       => $args{y_label}       // 'Y',
        width         => $args{width}         // 800,
        height        => $args{height}        // 600,
        graph_options => $args{graph_options} // {},  # extra GD::Graph options
    };

    return bless $self, $class;
}

=head2 generate_png_data

  my $png = $pg->generate_png_data(
      x => \@x,
      y => \@y,
  );

Returns raw PNG bytes (scalar string). Does NOT touch the filesystem.

=cut

sub generate_png_data {
    my ($self, %args) = @_;

    my $x = $args{x} or croak "Missing required parameter: x";
    my $y = $args{y} or croak "Missing required parameter: y";

    croak "x and y must be ARRAYREFs"
        unless ref($x) eq 'ARRAY' && ref($y) eq 'ARRAY';

    croak "x and y must be same length"
        unless @$x == @$y;

    my @data = ($x, $y);

    my $graph = GD::Graph::lines->new($self->{width}, $self->{height});
    $graph->set(
        x_label   => $self->{x_label},
        y_label   => $self->{y_label},
        title     => $self->{title},
        line_width => 2,
        dclrs      => ["blue"],
        %{ $self->{graph_options} || {} },  # allow custom options
    ) or croak $graph->error;

    my $gd = $graph->plot(\@data)
        or croak $graph->error;

    return $gd->png;
}

=head2 generate

  $pg->generate(
      x      => \@x,
      y      => \@y,
      output => "out.png",
  );

Keeps the old behavior: writes PNG to a file.

=cut

sub generate {
    my ($self, %args) = @_;

    my $output = $args{output} or croak "Missing required parameter: output";

    my $png_data = $self->generate_png_data(%args);

    open(my $fh, '>', $output) or croak "Cannot open $output: $!";
    binmode $fh;
    print $fh $png_data;
    close $fh;

    return $output;
}

1;
