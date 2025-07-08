import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/providers/user_provider.dart';

class RestaurantSelector extends StatefulWidget {
  final int? selectedRestaurantId;
  final Function(int) onRestaurantChanged;
  final bool showLabel;

  const RestaurantSelector({
    Key? key,
    this.selectedRestaurantId,
    required this.onRestaurantChanged,
    this.showLabel = true,
  }) : super(key: key);

  @override
  State<RestaurantSelector> createState() => _RestaurantSelectorState();
}

class _RestaurantSelectorState extends State<RestaurantSelector> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.hasRestaurants) {
          return Container();
        }

        final restaurants = userProvider.userRestaurantsAsInt;
        final selectedId =
            widget.selectedRestaurantId ?? userProvider.defaultRestaurantId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showLabel) ...[
              const Text(
                'Restaurant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedId,
                  isExpanded: true,
                  items: restaurants.map((restaurantId) {
                    return DropdownMenuItem<int>(
                      value: restaurantId,
                      child: Text('Restaurant #$restaurantId'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      widget.onRestaurantChanged(newValue);
                      userProvider.setDefaultRestaurant(newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
