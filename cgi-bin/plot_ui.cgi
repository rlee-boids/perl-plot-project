#!/usr/bin/env perl
use strict;
use warnings;
use CGI qw(:standard);
use JSON qw(decode_json);
use MIME::Base64 qw(encode_base64);
use FindBin;
use lib "$FindBin::Bin/../lib";

use Plot::Generator;

# Determine if this is a POST with JSON data
my $method    = request_method() || $ENV{REQUEST_METHOD} || 'GET';
my $json_text = param('json_data') // '';

my $plot_data_uri;
my $error;

if ($method eq 'POST' && $json_text ne '') {
    my $data;
    eval {
        $data = decode_json($json_text);
        1;
    } or do {
        $error = "Invalid JSON: $@";
    };

    if (!$error) {
        # Expect JSON fields: x, y, optional x_label, y_label, title, graph_options
        my $x = $data->{x};
        my $y = $data->{y};

        if (ref($x) ne 'ARRAY' || ref($y) ne 'ARRAY') {
            $error = "JSON must contain array fields 'x' and 'y'.";
        } elsif (@$x != @$y) {
            $error = "Arrays 'x' and 'y' must have the same length.";
        } else {
            my $pg = Plot::Generator->new(
                title         => $data->{title}    // "Generated Plot",
                x_label       => $data->{x_label}  // "X",
                y_label       => $data->{y_label}  // "Y",
                graph_options => $data->{graph_options} // {},
            );

            my $png = eval { $pg->generate_png_data(x => $x, y => $y) };
            if ($@) {
                $error = "Error generating plot: $@";
            } else {
                my $b64 = encode_base64($png, '');  # no newlines
                $plot_data_uri = "data:image/png;base64,$b64";
            }
        }
    }
}

print header(-type => 'text/html; charset=utf-8');
print start_html(
    -title => 'Perl JSON Plotter',
    -style => [
        'body { font-family: sans-serif; margin: 2rem; }',
        'textarea { width: 100%; height: 200px; font-family: monospace; }',
        '.error { color: red; font-weight: bold; }',
        '.plot-container { margin-top: 2rem; }',
    ],
);

print h1('Perl JSON Plotter');

if ($error) {
    print div({ class => 'error' }, escapeHTML($error));
}

my $sample_json = <<'JSON';
{
  "x": [0, 1, 2, 3, 4, 5],
  "y": [10, 12, 18, 25, 40, 55],
  "title": "Requests over time",
  "x_label": "Hours",
  "y_label": "Requests",
  "graph_options": {
    "bgclr": "white",
    "fgclr": "black",
    "long_ticks": 1
  }
}
JSON

print start_form(
    -method => 'POST',
    -action => url()
);
print p("Paste JSON describing your data (x/y arrays & optional labels):");
print textarea(
    -name    => 'json_data',
    -default => $json_text || $sample_json,
);
print p(submit(-value => 'Generate Plot'));
print end_form();

if ($plot_data_uri) {
    print div({ class => 'plot-container' },
        h2('Generated Plot'),
        img({ src => $plot_data_uri, alt => 'Generated Plot' })
    );
}

print end_html();

sub request_method {
    return $ENV{REQUEST_METHOD};
}
