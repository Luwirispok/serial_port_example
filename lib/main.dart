import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serial_port_example/extensions.dart';
import 'package:serial_port_example/serial_port_provider.dart';

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
      children: [
        const SizedBox(height: 4),
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
        const SizedBox(height: 4),
        FilledButton(
          onPressed: provider.read,
          child: const Text('Read'),
        ),
        const SizedBox(height: 4),
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
        const SizedBox(height: 4),
        FilledButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.green),
          ),
          onPressed: () => provider.updateState.call('-----------'),
          child: const Text('Write line'),
        ),
        const SizedBox(height: 4),
        const Divider(),
        const SizedBox(height: 4),
        FilledButton(
          onPressed: provider.getPorts,
          child: const Text('Get ports'),
        ),
        const SizedBox(height: 4),
        _buildListPorts(provider),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildListPorts(SerialPortProvider provider) {
    return Column(
      children: [
        for (final port in provider.ports)
          ExpansionTile(
            title: Text(port.toString()),
            children: [
              const SizedBox(height: 4),
              FilledButton(
                onPressed: () => provider.initPort(port),
                child: const Text('Change selected port'),
              ),
              const SizedBox(height: 4),
              const Divider(),
              CardListTile('Description', port.description),
              CardListTile('Transport', port.transport.toTransport()),
              CardListTile('USB Bus', port.busNumber?.toPadded()),
              CardListTile('USB Device', port.deviceNumber?.toPadded()),
              CardListTile('Vendor ID', port.vendorId?.toHex()),
              CardListTile('Product ID', port.productId?.toHex()),
              CardListTile('Manufacturer', port.manufacturer),
              CardListTile('Product Name', port.productName),
              CardListTile('Serial Number', port.serialNumber),
              CardListTile('MAC Address', port.macAddress),
            ],
          ),
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
