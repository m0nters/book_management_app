import 'package:flutter/material.dart';
import '../../routing/overall_screen_routing.dart';
import '../setting/setting.dart';

/// The `controller` property is required and should be used to manage the
/// text input. The `onSubmitted` callback is optional and can be used to
/// perform search actions when the user submits their query.
class HomeSearchBarCore extends StatelessWidget {
  final Function(int)
    mainScreenContextSwitcher;

  // Constructor
  const HomeSearchBarCore({
    super.key,
    required this.mainScreenContextSwitcher,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromRGBO(47, 54, 69, 1), // Background color of the container
      elevation: hasShadow ? 5 : 0,
      borderRadius: BorderRadius.circular(50.0), // Rounded corners
      child: InkWell(
        splashColor: Colors.blue,
        borderRadius: BorderRadius.circular(50.0), // Match the Material's border radius
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 200)); // Adjust delay as needed
          mainScreenContextSwitcher(OverallScreenContexts.advancedSearch.index);
        },
        child: Container(
          height: 43,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
          child: const Row(
            children: [
              Icon(
                Icons.search,
                color: Color.fromRGBO(235, 244, 246, 1),
                size: 25,
              ),
              SizedBox(width: 12.0),

              Text("Tìm kiếm nâng cao", style: TextStyle(
                  color: Color.fromRGBO(235, 244, 246, 1), fontSize: 16.0),),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeFunctionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const HomeFunctionButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(47, 54, 69, 1),
        foregroundColor: const Color.fromRGBO(235, 244, 246, 1),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: hasShadow ? 5 : 0,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
                fontSize: 16.0, color: Color.fromRGBO(235, 244, 246, 1)),
          ),
          const Icon(Icons.add_circle, color: Color.fromRGBO(235, 244, 246, 1)),
        ],
      ),
    );
  }
}
