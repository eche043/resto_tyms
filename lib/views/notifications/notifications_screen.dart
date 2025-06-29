import 'package:odrive_restaurant/common/const/const.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BgContainer(),
          const CustomAppBar(
            leadingImageAsset: drawer,
            smsImageAsset: mailIcon,
            title: 'Notifications',
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 10.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        //  height: 75,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: blue, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: grey.withOpacity(0.4),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(5, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  maxRadius: 20,
                                  backgroundImage: AssetImage(shwarma),
                                ),
                                6.widthBox,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    'Coupon Available'
                                        .text
                                        .color(fontGrey)
                                        .semiBold
                                        .size(12)
                                        .make(),
                                    '20% off Available for next order'
                                        .text
                                        .overflow(TextOverflow.ellipsis)
                                        .color(fontGrey.withOpacity(0.7))
                                        .normal
                                        .size(10)
                                        .make(),
                                    '2024-05-22  24:00:00'
                                        .text
                                        .overflow(TextOverflow.ellipsis)
                                        .color(fontGrey.withOpacity(0.7))
                                        .normal
                                        .size(10)
                                        .make(),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    'Mark all as Read'
                                        .text
                                        .overflow(TextOverflow.ellipsis)
                                        .color(fontGrey.withOpacity(0.7))
                                        .normal
                                        .size(10)
                                        .make(),
                                    8.heightBox,
                                    Container(
                                      height: 25,
                                      width: 70,
                                      decoration: BoxDecoration(
                                          color: appColor,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                        child: 'Buy Now'
                                            .text
                                            .overflow(TextOverflow.ellipsis)
                                            .color(white)
                                            .normal
                                            .size(10)
                                            .make(),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
