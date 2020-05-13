#! /usr/bin/env perl
use warnings;
use strict;

use Mojo::DOM;

use constant TARGET_ID => "make-everything-ok-button";

use constant SCORE_MATCH => 45; # Total score required for treat the element as matched
use constant SCORE_TEXT  => 15; # Score for match text (exact match)
use constant SCORE_TAG   => 15; # Score for match element tag
use constant SCORE_ATTR  => {   # Score for matched attributes (exact)
    class   => 10,
    title   => 10,
    style   => 10,
    onclick => 10,
    href    => 5,
};

sub main {
    my ($original, $differ) = @_;

    my $dom_orig  = xml_parse($original);
    my $orig_node = orig_node($dom_orig)
        or die "Can't find original node\n";

    my $dom_differ = xml_parse($differ);
    my $matched_node = find_matched_node($orig_node, $dom_differ);
    if ($matched_node) {
        print build_xpath($matched_node), "\n";
    }
    return $matched_node ? 0 : 1;
}

sub xml_parse {
    my $filename = shift;
    my $dom = Mojo::DOM->new;
    $dom->parse(read_file($filename))
        or die "Cannot parse $filename\n";
    return $dom;
}

sub orig_node {
    my $dom_orig = shift;
    my $nodes = $dom_orig->find('#' . TARGET_ID);
    return $nodes ? $nodes->first : undef;
}

sub read_file {
    my $filename = shift;
    open my $fh, '<', $filename
        or die "Can't open $filename: $!\n";
    local $/;
    my $text = <$fh>;
    close $fh;
    return $text;
}

sub find_matched_node {
    my ($orig_node, $dom) = @_;
    my $matched_node;
    for my $node ($dom->find('*')->each) {
        if (is_similar($orig_node, $node)) {
            die "More then one matched node found\n" if $matched_node;
            $matched_node = $node;
        }
    }
    return $matched_node;
}

sub is_similar {
    my ($orig_node, $diff_node) = @_;
    my $score = 0;
    $score += SCORE_TEXT if $orig_node->text eq $diff_node->text;
    $score += SCORE_TAG  if $orig_node->tag  eq $diff_node->tag;
    foreach my $attr (keys %{&SCORE_ATTR}) {
        if (($orig_node->attr($attr) // '') eq ($diff_node->attr($attr) // '')) {
            $score += SCORE_ATTR->{$attr};
        }
    }
    return $score >= SCORE_MATCH;
}

sub build_xpath {
    my $node = shift;
    # Build xpath of the element with selector $node->selector
    my $xpath = '';
    for my $node ($node->ancestors->reverse->each, $node) {
        my $count = $node->preceding($node->tag)->each;
        if ($count || $node->next($node->tag)) {
            $xpath .= '/' . $node->tag . "[" . ($count+1) . "]";
        }
        else {
            # Only one element with this tag on the level, index is not needed
            $xpath .= '/' . $node->tag;
        }
    }
    return $xpath;
}

if (@ARGV != 2) {
    print "Find element similar to the original in the html document\n";
    print "Usage: $0 <original-file> <differ-file>\n";
    exit(0);
}

exit main(@ARGV);
