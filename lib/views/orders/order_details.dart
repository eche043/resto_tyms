import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/common/widgets/distance_calculator.dart';
import 'package:odrive_restaurant/model/order.dart';

class OrderDetails extends StatefulWidget {
  Order order;
  DistanceCalculatorWidget distance;
  bool history;
  Function(int) acceptSuccess;
  OrderDetails(
      {super.key,
      required this.order,
      required this.distance,
      required this.history,
      required this.acceptSuccess});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          const BgContainer(),
          const CustomAppBar(
            leadingImageAsset: drawer,
            title: 'Order Details',
            notificationImageAsset: notificationIcon,
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 20.0,
            left: 4,
            right: 4,
            bottom: 0,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                //OrdersDetailCard1(),
                /* SizedBox(
                  height: 12,
                ), */
                OrdersDetailCard2(
                    order: widget.order,
                    distance: widget.distance,
                    history: widget.history,
                    acceptSuccess: widget.acceptSuccess),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
