import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../screens/edit_regulation/edit_regulation.dart';
import 'main_screen_routing.dart';
import '../screens/advanced_search/advanced_search.dart';
import '../screens/setting/setting.dart';
import '../screens/internet_connection_resolving/no_internet_connection.dart';
import '../screens/internet_connection_resolving/reconnecting.dart';
import 'package:http/http.dart' as http;

Future<bool> _isConnectionStable() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'), headers: {'Connection': 'close'});
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

enum MainFunctionsContexts {
  home,
  bookEntryForm,
  bookSaleInvoice,
  bill,
  outstandingReport,
}

enum OverallScreenContexts {
  mainFunctions,
  advancedSearch,
  editRegulation,
  setting,
  noInternetConnection,
  reconnecting
}

class OverallScreenRouting extends StatefulWidget {
  const OverallScreenRouting({super.key});

  @override
  createState() => _OverallScreenRoutingState();
}

class _OverallScreenRoutingState extends State<OverallScreenRouting> {
  int _selectedIndex = OverallScreenContexts.mainFunctions.index; // placeholder
  static late Map<int, Widget> _contextOptions;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    _contextOptions = {
      OverallScreenContexts.mainFunctions.index:
      MainFunctionsRouting(overallScreenContextSwitcher: switchContext),
      OverallScreenContexts.advancedSearch.index:
      AdvancedSearch(overallScreenContextSwitcher: switchContext),
      OverallScreenContexts.editRegulation.index:
      EditRegulation(overallScreenContextSwitcher: switchContext),
      OverallScreenContexts.setting.index:
      Setting(overallScreenContextSwitcher: switchContext),
      OverallScreenContexts.noInternetConnection.index:
      const NoInternetConnection(),
      OverallScreenContexts.reconnecting.index:
      const Reconnecting()
    };

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateScreenContext);
  }

  void _updateScreenContext(List<ConnectivityResult> result) async {
    bool hasInternet = result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi);
    if (hasInternet) {
      setState(() {
        _selectedIndex = OverallScreenContexts.reconnecting.index;
      });
    }
    bool isStable = hasInternet ? await _isConnectionStable() : false;
    setState(() {
      _selectedIndex = isStable
          ? OverallScreenContexts.mainFunctions.index
          : OverallScreenContexts.noInternetConnection.index;
    });
  }

  void switchContext(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _contextOptions[_selectedIndex]!;
  }
}
