import 'sort.dart';

abstract class Pageable {
  int get page;

  int get size;

  int get offset;

  Sort get sort;

  Pageable next();

  Pageable previous();

  Pageable first();

  Pageable withPage(int pageNumber);

  bool hasPrevious();
}
