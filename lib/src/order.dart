enum Direction { asc, desc }

class Order {
  final String property;
  final Direction direction;

  const Order.asc(this.property) : direction = Direction.asc;

  const Order.desc(this.property) : direction = Direction.desc;
}

class Sort {
  final List<Order> orders;

  const Sort.by(this.orders);
}
