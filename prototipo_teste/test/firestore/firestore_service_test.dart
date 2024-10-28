import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Generate mocks with unique names
@GenerateMocks([FirebaseFirestore])
@GenerateMocks([], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockFuncionariosCollection,
  ),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(
    as: #MockFuncionariosQuerySnapshot,
  ),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(
    as: #MockFuncionariosDocumentSnapshot,
  ),
])

// Import the generated mocks
import 'firestore_service_test.mocks.dart';

void main() {
  group('Firestore Connection Test', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFuncionariosCollection mockCollection;
    late MockFuncionariosQuerySnapshot mockQuerySnapshot;
    late MockFuncionariosDocumentSnapshot mockDocumentSnapshot;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockFuncionariosCollection();
      mockQuerySnapshot = MockFuncionariosQuerySnapshot();
      mockDocumentSnapshot = MockFuncionariosDocumentSnapshot();

      // Set up the mock chain
      when(mockFirestore.collection('funcionarios'))
          .thenReturn(mockCollection);
      
      when(mockCollection.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      
      when(mockQuerySnapshot.docs)
          .thenReturn([mockDocumentSnapshot]);
      
      when(mockDocumentSnapshot.data())
          .thenReturn({'name': 'Funcionario 1', 'id': '1'});
    });

    test('Verifica se Firestore retorna dados da coleção de funcionários', () async {
      // Get the collection reference
      final collectionRef = mockFirestore.collection('funcionarios');
      expect(collectionRef, equals(mockCollection));

      // Get the snapshot
      final snapshot = await collectionRef.get();
      expect(snapshot, equals(mockQuerySnapshot));

      // Verify the data
      expect(snapshot.docs.length, equals(1));
      expect(snapshot.docs.first.data(), 
          equals({'name': 'Funcionario 1', 'id': '1'}));

      // Verify the method calls
      verify(mockFirestore.collection('funcionarios')).called(1);
      verify(mockCollection.get()).called(1);
      verify(mockQuerySnapshot.docs).called(2);
      verify(mockDocumentSnapshot.data()).called(1);
    });
    
    test('Verifica se retorna lista vazia quando não há documentos', () async {
      // Setup empty response
      when(mockQuerySnapshot.docs).thenReturn([]);
      
      // Get the collection reference
      final collectionRef = mockFirestore.collection('funcionarios');
      final snapshot = await collectionRef.get();
      
      // Verify empty result
      expect(snapshot.docs.isEmpty, true);
      verify(mockQuerySnapshot.docs).called(1);
    });
  });
}