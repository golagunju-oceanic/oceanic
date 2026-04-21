import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:oceanic/presentation/widgets/drawer.dart';

class FindProvider extends ConsumerStatefulWidget {
  const FindProvider({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FindProviderState();
  }
}

class _FindProviderState extends ConsumerState<FindProvider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      drawer: CustomDrawer(),
      body: Column(children: [Text(''), Text(''), Text('')]),
    );
  }
}
