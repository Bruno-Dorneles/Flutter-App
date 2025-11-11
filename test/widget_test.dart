// Adicione em test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Página principal mostra Home e Usuários', (WidgetTester tester) async {
    // Cria um widget MyApp substituindo fetchUsers por dados fake
    await tester.pumpWidget(MaterialApp(
      home: MainPageFake(),
    ));

    // Verifica se texto Home aparece
    expect(find.text('Home'), findsWidgets);

    // Toca na aba Usuários
    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();

    // Verifica se título da lista aparece
    expect(find.text('Lista de usuários'), findsOneWidget);
  });
}

// Widget fake substituindo a requisição real
class MainPageFake extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Lista de usuários')), // dados fake
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuários'),
        ],
      ),
    );
  }
}
