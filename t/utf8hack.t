use strict;
use warnings;
use utf8;   # <- here is the point for this test
use Encode qw( encode_utf8 decode_utf8 );
use Test::More;
use Test::Differences;
use Test::Name::FromLine ':utf8';

sub x ($) { my $s = shift; $s =~ s{^\s+|\s+$}{}g; $s }
sub test_test (&) { # from Test::Test::More written by id:wakabatan
	my $code = shift;
	#                 v- here is also the point for this test
	open my $file1, '>:utf8', \(my $s = '');

	{
		my $builder = Test::Builder->create;
		$builder->output($file1);
		no warnings 'redefine';
		local *Test::More::builder = sub { $builder };
		$code->();
	}

	close $file1;

	return { output => x $s };
}

is test_test {
	is   1,    1;       # マルチバイトコメント
	is   'あ', 'あ';
	like 'あ', qr{あ};
} -> {output}, x encode_utf8 q{
ok 1 - L29: is   1,    1;       \# マルチバイトコメント
ok 2 - L30: is   'あ', 'あ';
ok 3 - L31: like 'あ', qr{あ};
}, 'multibyte ok';

is test_test {
	TODO: {
		local $TODO = 'あとで';
		is   1,    1;       # マルチバイトコメント
		is   'あ', 'あ';
		like 'あ', qr{あ};
	};
} -> {output}, x encode_utf8 q{
ok 1 - L41: is   1,    1;       \# マルチバイトコメント # TODO あとで
ok 2 - L42: is   'あ', 'あ'; # TODO あとで
ok 3 - L43: like 'あ', qr{あ}; # TODO あとで
}, 'todo ok';

done_testing;
