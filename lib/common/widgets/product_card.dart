import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String orderId;
  final String updateDate;
  final String imageUrl;
  final bool isPublished;
  final Function onPublish;
  final Function onEdit;
  final Function(String status) onDelete;
  final bool isLoading;

  ProductCard({
    required this.title,
    required this.orderId,
    required this.updateDate,
    required this.imageUrl,
    required this.isPublished,
    required this.onPublish,
    required this.onEdit,
    required this.onDelete,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    ProductsProvider productsProvider = Provider.of<ProductsProvider>(context);
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: greyScale900Color),
                              ),
                              SizedBox(height: 5),
                              Text(
                                orderId,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: greyScale900Color,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Image.asset(icCalender),
                                  SizedBox(width: 4),
                                  Text(
                                    updateDate,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 80,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPublished
                                      ? appColor
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isPublished ? "Published" : "Draft",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(12.0),
                  // ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: onEdit(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(
                        "Edit",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  10.widthBox,
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: productsProvider.isDeleting(orderId)
                          ? () {}
                          : () {
                              print("Delete");
                              productsProvider.foodDelete(orderId, (status) {
                                onDelete(status);
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: productsProvider.isDeleting(orderId)
                          ? const SpinKitCircle(color: Colors.white, size: 20.0)
                          : Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
