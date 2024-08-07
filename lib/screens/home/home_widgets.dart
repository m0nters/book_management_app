import 'package:flutter/material.dart';
import '../../routing/overall_screen_routing.dart';
import '../setting/setting.dart';

/// The `controller` property is required and should be used to manage the
/// text input. The `onSubmitted` callback is optional and can be used to
/// perform search actions when the user submits their query.
class HomeSearchBarCore extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)?
      onSubmitted; // Function to handle search submission (optional)
  final Function(int)
      mainFunctionsContextSwitcher;
  final Function(int)
    mainScreenContextSwitcher;

  // Constructor
  const HomeSearchBarCore({
    super.key,
    required this.controller,
    this.onSubmitted,
    required this.mainFunctionsContextSwitcher,
    required this.mainScreenContextSwitcher,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(47, 54, 69, 1), // Background color
        borderRadius: BorderRadius.circular(50.0), // Rounded corners
        boxShadow: hasShadow ? const [
          BoxShadow(
            offset: Offset(0, 4),
            color: Colors.grey,
            blurRadius: 4,
          )
        ] : null,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color.fromRGBO(235, 244, 246, 1),
            size: 25,
          ),
          const SizedBox(width: 12.0),

          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                  color: Color.fromRGBO(235, 244, 246, 1), fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Nhập thông tin gì đó (tên sách, tác giả,...)',
                hintStyle: TextStyle(
                    color: Color.fromRGBO(133, 133, 133, 1), fontSize: 14),
                border: InputBorder.none, // Remove default border
              ),
              onSubmitted: onSubmitted,
            ),
          ),

          // Advanced search button
          IconButton(
            icon: const Icon(
              Icons.manage_search,
              color: Color.fromRGBO(235, 244, 246, 1),
              size: 30,
            ),
            onPressed: () {
              mainScreenContextSwitcher(OverallScreenContexts.advancedSearch.index);
            },
          ),
        ],
      ),
    );
  }
}

class HomeSearchBar extends StatefulWidget {
  final Function(int) mainFunctionsContextSwitcher;
  final Function(int) mainScreenContextSwitcher;

  const HomeSearchBar(
      {super.key,
      required this.mainFunctionsContextSwitcher,
      required this.mainScreenContextSwitcher});

  @override
  createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = ''; // To store the current query

  void _handleSearchSubmit(String query) {
    setState(() {
      searchQuery = query;
    });
    // Perform your search logic here based on the 'searchQuery'
    // For example, you could call an API, filter a list, etc.
  }

  @override
  void dispose() {
    _searchController.dispose(); // Remember to dispose the controller
    super.dispose();
  }

  String _formatSearchQuery(String query) {
    const int maxQueryLength = 30;
    if (query.length > maxQueryLength) {
      query = '${query.substring(0, maxQueryLength)}...';
    }
    return 'Tìm kiếm cho "$query": 0 kết quả';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSearchBarCore(
          controller: _searchController,
          onSubmitted: _handleSearchSubmit,
          mainFunctionsContextSwitcher: widget.mainFunctionsContextSwitcher,
          mainScreenContextSwitcher: widget.mainScreenContextSwitcher,
        ),
        // Display search results based on 'searchQuery'
        Opacity(
          opacity: searchQuery.trim().isNotEmpty ? 1.0 : 0.0,
          child: Text(
            _formatSearchQuery(searchQuery),
          ),
        ),
      ],
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
