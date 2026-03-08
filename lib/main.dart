import 'package:flutter/material.dart';

void main() {
  runApp(const IoTLabApp());
}

class IoTLabApp extends StatelessWidget {
  const IoTLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Flutter Lab 1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const IoTLabHomePage(),
    );
  }
}

enum DeviceMode { normal, eco, locked }

class IoTLabHomePage extends StatefulWidget {
  const IoTLabHomePage({super.key});

  @override
  State<IoTLabHomePage> createState() => _IoTLabHomePageState();
}

class _IoTLabHomePageState extends State<IoTLabHomePage> {
  final TextEditingController _controller = TextEditingController();

  int _counter = 0;
  int _step = 1;
  DeviceMode _mode = DeviceMode.normal;

  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _modeLabel(DeviceMode mode) {
    switch (mode) {
      case DeviceMode.normal:
        return 'NORMAL';
      case DeviceMode.eco:
        return 'ECO';
      case DeviceMode.locked:
        return 'LOCKED';
    }
  }

  IconData _modeIcon(DeviceMode mode) {
    switch (mode) {
      case DeviceMode.normal:
        return Icons.settings_remote;
      case DeviceMode.eco:
        return Icons.energy_savings_leaf;
      case DeviceMode.locked:
        return Icons.lock;
    }
  }

  void _applyInput() {
    final raw = _controller.text.trim();

    setState(() {
      _errorText = null;
    });

    if (raw.isEmpty) {
      setState(() {
        _errorText = 'Input number or command';
      });
      return;
    }

    // Magic command
    if (raw.toLowerCase() == 'avada kedavra') {
      setState(() {
        _counter = 0;
        _mode = DeviceMode.locked;
      });
      _showSnack('Counter reset. Device in LOCKED mode.');
      return;
    }

    // Режими IoT
    final cmd = raw.toLowerCase();
    if (cmd == 'eco' || cmd == 'lock') {
      setState(() {
        _mode = switch (cmd) {
          'eco' => DeviceMode.eco,
          _ => DeviceMode.locked,
        };
      });
      _showSnack('The mode is set: ${_modeLabel(_mode)}');
      return;
    }

    // Число -> міняємо крок
    final parsed = int.tryParse(raw);
    if (parsed != null) {
      if (parsed < 1 || parsed > 999) {
        setState(() {
          _errorText = 'The number must be between 1..999.';
        });
        return;
      }
      setState(() {
        _step = parsed;
      });
      _showSnack('Increment step = $_step');
      return;
    }

    setState(() {
      _errorText = 'Unknown command. Try it: 5 / eco / lock / Avada Kedavra';
    });
  }

  void _incrementCounter() {
    if (_mode == DeviceMode.locked) {
      _showSnack('LOCKED: unlock with the command eco/normal (hint: enter "eco")');
      return;
    }

  final int delta = switch (_mode) {
    DeviceMode.eco => 1,
    DeviceMode.normal => _step,
    DeviceMode.locked => 0,
  };

    setState(() {
      _counter += delta;
    });
  }

  void _setNormal() {
    setState(() {
      _mode = DeviceMode.normal;
    });
    _showSnack('The mode is set: NORMAL');
  }

  @override
  Widget build(BuildContext context) {
    final modeLabel = _modeLabel(_mode);
    final icon = _modeIcon(_mode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Flutter Lab 1'),
        actions: [
          IconButton(
            tooltip: 'Set NORMAL mode',
            onPressed: _setNormal,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(icon, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device mode: $modeLabel',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text('Step: $_step  •  Counter: $_counter'),
                        ],
                      ),
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Command or number',
                hintText: 'For example: 5, eco, lock, Avada Kedavra',
                errorText: _errorText,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: 'Clean up',
                  onPressed: () {
                    _controller.clear();
                    setState(() => _errorText = null);
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              onSubmitted: (_) => _applyInput(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applyInput,
                    icon: const Icon(Icons.check),
                    label: const Text('Apply'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _counter = 0;
                        _step = 1;
                        _mode = DeviceMode.normal;
                        _errorText = null;
                      });
                      _controller.clear();
                      _showSnack('Status reset to default.');
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset all'),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Hint: mode affects increment:\n'
              'ECO = +1, NORMAL = +step, LOCKED = блок.\n'
              'Commands: eco / lock / Avada Kedavra / number',
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}