enum Direction { asc, desc }

class Order {
  final String property;
  final Direction direction;

  Order.asc(this.property) : direction = Direction.asc;

  Order.desc(this.property) : direction = Direction.desc;
}

class Sort {
  final List<Order> orders;

  Sort.by(this.orders);
}
