package Catalyst::TraitFor::Controller::jQuery::jqGrid;
use 5.008;

our $VERSION   = '0.01';
$VERSION = eval $VERSION;

use Moose::Role;
use POSIX qw(ceil);

use namespace::autoclean;

#
# page_params:
#
# Common role to calculate the paging parameters
#
sub jqgrid_page {
    my ($self, $c, $result_set) = @_;

    my $config = $c->config->{'Catalyst::TraitFor::Controller::jQuery::jqGrid'};
    my $page_key = 'page';
    my $rows_key = 'rows';
    my $sidx_key = 'sidx';
    my $sord_key = 'sord';
    my $json_key = 'json_data';

    if ($config) {
        $page_key = $config->{page_key} || 'page';
        $rows_key = $config->{rows_key} || 'rows';
        $sidx_key = $config->{sidx_key} || 'sidx';
        $sord_key = $config->{sord_key} || 'sord';
        $json_key = $config->{json_key} || 'json_data';
    }

    my $page        = $c->request->param($page_key) || 0;
    my $rows        = $c->request->param($rows_key) || 10;
    my $index_row   = $c->request->param($sidx_key);
    my $sort_order  = $c->request->param($sord_key);

    # get the count of the maximum number of records
    my $records = $result_set->count();

    my $total_pages = $records > 0 ? ceil($records / $rows) : 0;

    if ($page > $total_pages) {
        $page = $total_pages;
    }

    if ($index_row && $sort_order) {

        my $order_by = { -asc => $index_row };
        if (lc($sort_order) eq 'desc') {
            $order_by = { - desc => $index_row };
        }

        $result_set = $result_set->search({}, {
            order_by    => $order_by,
            page        => $page,
            rows        => $rows,
        });
    }
    else {
        $result_set = $result_set->search({}, {
            page        => $page,
            rows        => $rows,
        });
    }

    $c->stash->{$json_key}{page}    = $page;
    $c->stash->{$json_key}{total}   = $total_pages;
    $c->stash->{$json_key}{records} = $records;

    return $result_set;
}

1;
