#   $Id: 207-parse-classes-uindxn.t,v 1.2 2009/02/26 13:49:07 aff Exp $

use warnings;
use strict;

use Data::Dumper;
use Test::More;
use File::Spec::Functions;
use lib catdir qw ( blib lib );

plan tests => 47;

use_ok ('Parse::Dia::SQL');

my $diasql =  Parse::Dia::SQL->new( file => catfile(qw(t data TestERD.dia)), db => 'db2' );
isa_ok($diasql, q{Parse::Dia::SQL}, q{Expect a Parse::Dia::SQL object});

# TODO: Add test on return value - call wrapper
$diasql->convert();

my $classes = $diasql->get_classes_ref();

# Expect an array ref with 14 elements
isa_ok($classes, 'ARRAY');
cmp_ok(scalar(@$classes), q{==}, 14, q{Expect 14 classes});

# Hash with class/view names as keys and unique index (if any) as
# (hashref) elements
my %uindxn = (
    imageInfo => { 'idx_iimd5' => [ [ 'md5sum', 'char (32)' ] ] },
    subImageInfo      => {},
    imageCategoryList => {},
    categoryNames     => {},
    imageAttribute    => {},
    userInfo          => {
        'idx_uinm' => [ [ 'name', 'varchar (32)' ], [ 'md5sum', 'char (32)' ] ]
    },
    userAttribute     => {},
    userImageRating   => {},
    attributeCategory => {},
    userSession       => {},
    extremes          => {},
    ratings_view      => {},
    whorated_view     => {},
    users_view        => {},
);


# Check that each class has of the expected uindxn attributes
foreach my $class (@$classes) {
  isa_ok($class, 'HASH');
  ok(exists($uindxn{$class->{name}})) or
	diag($class->{name} . ' uindxn :' . Dumper($class->{uindxn}));

  # check contents
  is_deeply(
 			$class->{uindxn},
 			$uindxn{ $class->{name} },
 			q{uindxn for } . $class->{name}
 		   );

  # remove class from hash
  delete $uindxn{$class->{name}};
} 

# Expect no classes left now
cmp_ok(scalar(keys %uindxn), q{==}, 0, q{Expect 0 classes left});

__END__

