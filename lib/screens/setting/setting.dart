import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../routing/overall_screen_routing.dart';

bool hasShadow = true;
int lowOnStockThreshold = 100;
const int maxStockThreshold = 500; // Define the maximum allowed value

class Setting extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;

  const Setting({super.key, required this.overallScreenContextSwitcher});

  @override
  createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextEditingController _thresholdController = TextEditingController();
  bool _isShowingSnackBar = false;

  @override
  void initState() {
    super.initState();
    _thresholdController.text = lowOnStockThreshold.toString();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _showLimitExceedError(BuildContext context) {
    if (_isShowingSnackBar) return; // Prevent spamming button

    _isShowingSnackBar = true; // Set saving state to true

    ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(
            content: Text('Ngưỡng ít hàng tối đa là $maxStockThreshold'),
            duration: Duration(seconds: 2),
          ),
        )
        .closed
        .then((reason) {
      _isShowingSnackBar =
          false; // Reset saving state after snack bar is closed
    });
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Cài đặt",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
              onPressed: () {
                widget.overallScreenContextSwitcher(
                    OverallScreenContexts.mainFunctions.index);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: Column(
            children: [
              // Shadow effect toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Hiệu ứng đổ bóng",
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  Switch(
                    value: hasShadow,
                    onChanged: (value) {
                      setState(() {
                        hasShadow = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Low stock threshold adjustment
              Row(
                children: [
                  const Text(
                    "Ngưỡng ít hàng",
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        int? enteredValue = int.tryParse(value);
                        if (enteredValue != null) {
                          if (enteredValue <= maxStockThreshold) {
                            setState(() {
                              lowOnStockThreshold = enteredValue;
                            });
                          } else {
                            _showLimitExceedError(context);
                            _thresholdController.text = lowOnStockThreshold
                                .toString(); // keep the current value, create an effect that does not let the user to type more
                          }
                        } else {
                          setState(() {
                            lowOnStockThreshold = 0;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              Slider(
                value: lowOnStockThreshold.toDouble(),
                min: 0,
                max: maxStockThreshold.toDouble(),
                divisions: maxStockThreshold,
                label: lowOnStockThreshold.toString(),
                onChanged: (value) {
                  setState(() {
                    lowOnStockThreshold = value.toInt();
                    _thresholdController.text = lowOnStockThreshold.toString();
                  });
                },
              ),
            ],
          ),
        ));
  }
}
