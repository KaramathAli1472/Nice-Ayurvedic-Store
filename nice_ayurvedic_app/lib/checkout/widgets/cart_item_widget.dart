class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function() onRemove;
  final Function(int) onUpdateQty;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onUpdateQty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(item.imageUrl, width: 50, height: 50),
        title: Text(item.name),
        subtitle: Text('₹${item.price}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () => onUpdateQty(item.quantity - 1),
            ),
            Text('${item.quantity}'),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => onUpdateQty(item.quantity + 1),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}