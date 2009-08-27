use strict;
use warnings;

use Test::More tests => 53;
use Test::Mock::LWP;

use_ok('Net::Lighthouse::Project');
use_ok('Net::Lighthouse::Project::Message');
can_ok( 'Net::Lighthouse::Project::Message', 'new' );

my $message = Net::Lighthouse::Project::Message->new;
isa_ok( $message, 'Net::Lighthouse::Project::Message' );
isa_ok( $message, 'Net::Lighthouse' );

my @attrs = (
    'created_at',        'comments',
    'body_html',         'user_name',
    'permalink',         'body',
    'comments_count',    'parent_id',
    'url',               'updated_at',
    'id',                'user_id',
    'project_id',        'all_attachments_count',
    'attachments_count', 'title',
);

for my $attr (@attrs) {
    can_ok( $message, $attr );
}

for my $method (qw/create update delete load load_from_xml list initial_state
        create_comment/)
{
    can_ok( $message, $method );
}

$Mock_ua->mock( get            => sub { $Mock_response } );
$Mock_ua->mock( default_header => sub { } );                  # to erase warning
$Mock_response->mock(
    content => sub {
        local $/;
        open my $fh, '<', 't/data/message_20298.xml' or die $!;
        <$fh>;
    }
);

my $m1 = Net::Lighthouse::Project::Message->new(
    account    => 'sunnavy',
    project_id => 35198,
);
my $load = $m1->load(20298);
is( $load, $m1, 'load return $self' );
my %hash = (
    'permalink'         => '1st-message',
    'parent_id'         => undef,
    'body'              => 'ha-ha ha-ha',
    'attachments_count' => '0',
    'created_at'        => '2009-08-27T07:29:05Z',
    'url' => 'http://sunnavy.lighthouseapp.com/projects/35918/messages/20298',
    'id'  => '20298',
    'comments_count'        => '3',
    'all_attachments_count' => '1',
    'project_id'            => '35918',
    'account'               => 'sunnavy',
    'user_name'             => 'sunnavy (at gmail)',
    'updated_at'            => '2009-08-27T07:44:33Z',
    'body_html'             => '<div><p>ha-ha ha-ha</p></div>',
    'title'                 => '1st message lala',
    'user_id'               => '67166'
);

for my $k ( keys %hash ) {
    is( $m1->$k, $hash{$k}, "$k is loaded" );
}

is( @{$m1->comments}, 3, 'comments number' );
isa_ok( $m1->comments->[0], 'Net::Lighthouse::Project::Message' );
is( $m1->comments->[0]->title, '1st message lala', 'first comment title' );
is( $m1->comments->[0]->id, '20299', 'first comment id' );

$Mock_response->mock(
    content => sub {
        local $/;
        open my $fh, '<', 't/data/messages.xml' or die $!;
        <$fh>;
    }
);

$message = Net::Lighthouse::Project::Message->new(
    account    => 'sunnavy',
    project_id => 35198,
);
my @list = $message->list;
is( scalar @list, 1, 'list number' );
is( $list[0]->id, 20298, 'message id' );

# test initial_state
$Mock_response->mock(
    content => sub {
        local $/;
        open my $fh, '<', 't/data/message_new.xml' or die $!;
        <$fh>;
    }
);
$message = Net::Lighthouse::Project::Message->new(
    account    => 'sunnavy',
    project_id => 35198,
);

my $expect_initial_state = {
    'parent_id'         => '',
    'permalink'         => '',
    'body'              => '',
    'attachments_count' => '0',
    'created_at'        => '',
    'updated_at'        => '',
    'title'             => '',
    'body_html'         => '',
    'user_id'           => '',
    'comments_count'    => '0',
    'project_id'        => ''

};
is_deeply( $message->initial_state, $expect_initial_state, 'initial state' );
