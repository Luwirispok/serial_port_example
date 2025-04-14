import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serial_port_example/serial_port_provider_win.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SerialPortProvider(),
      child: MaterialApp(
        home: _buildTabBar(context),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Serial Port example'),
      ),
      body: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: SingleChildScrollView(
              child: SerialPortExample(),
            ),
          ),
          VerticalDivider(),
          Flexible(child: StatusWidget()),
        ],
      ),
    );
  }
}

class SerialPortExample extends StatelessWidget {
  const SerialPortExample({super.key});

  @override
  Widget build(BuildContext context) {
    SerialPortProvider provider = context.watch<SerialPortProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 4,
      children: [
        FieldBaudRateWidget(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: provider.open,
              child: const Text('Open port'),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: provider.close,
              child: const Text('Close port'),
            ),
          ],
        ),
        FilledButton(
          onPressed: provider.read,
          child: const Text('Read'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: provider.streamPortsOpen,
              child: const Text('Stream open'),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: provider.streamPortsClose,
              child: const Text('Stream close'),
            ),
          ],
        ),
        FilledButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.green),
          ),
          onPressed: () => provider.updateState.call('-----------'),
          child: const Text('Write line'),
        ),
        const Divider(),
        FilledButton(
          onPressed: provider.getPorts,
          child: const Text('Get ports'),
        ),
        _buildListPorts(provider),
      ],
    );
  }

  Widget _buildListPorts(SerialPortProvider provider) {
    return Column(
      children: [
        for (final port in provider.ports)
          ExpansionTile(
            title: Text(port.portName),
            children: [
              FilledButton(
                onPressed: () => provider.initPort(port),
                child: const Text('Change selected port'),
              ),
              const Divider(),
              // CardListTile('Description', port.description),
              // CardListTile('Transport', port.transport.toTransport()),
              // CardListTile('USB Bus', port.busNumber?.toPadded()),
              // CardListTile('USB Device', port.deviceNumber?.toPadded()),
              // CardListTile('Vendor ID', port.vendorId?.toHex()),
              // CardListTile('Product ID', port.productId?.toHex()),
              // CardListTile('Manufacturer', port.manufacturer),
              // CardListTile('Product Name', port.productName),
              // CardListTile('Serial Number', port.serialNumber),
              // CardListTile('MAC Address', port.macAddress),
              CardListTile('USB Device', port.portName),
            ],
          ),
      ],
    );
  }
}

class FieldBaudRateWidget extends StatefulWidget {
  const FieldBaudRateWidget({
    super.key,
  });

  @override
  State<FieldBaudRateWidget> createState() => _FieldBaudRateWidgetState();
}

/// State for widget FieldWidget.
class _FieldBaudRateWidgetState extends State<FieldBaudRateWidget> {
  String text = '';
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SerialPortProvider provider = context.watch<SerialPortProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        SizedBox(
          width: 150,
          child: TextField(
            decoration: const InputDecoration(
                labelText: 'BaudRate', border: OutlineInputBorder()),
            controller: controller,
            onChanged: (value) => setState(() => text = value),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              provider.updateBaudRate(int.parse(text));
            },
            child: const Text('Обновить baudRate')),
      ],
    );
  }
}

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    SerialPortProvider provider = context.watch<SerialPortProvider>();
    List<String> status = provider.status.reversed.toList();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemBuilder: (context, index) =>
          SelectableText('${status.length - 1 - index}: ${status[index]}'),
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemCount: status.length,
    );
  }
}

class CardListTile extends StatelessWidget {
  final String name;
  final String? value;

  const CardListTile(this.name, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(value ?? 'N/A'),
        subtitle: Text(name),
      ),
    );
  }
}
