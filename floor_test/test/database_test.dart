import 'package:flutter_test/flutter_test.dart';

import 'database.dart';

// run test with 'flutter run test/database_test.dart'
void main() {
  group('database tests', () {
    TestDatabase database;

    setUpAll(() async {
      database = await TestDatabase.openDatabase();
    });

    tearDown(() async {
      await database.database.execute('DELETE FROM person');
    });

    test('database initially is empty', () async {
      final actual = await database.findAllPersons();

      expect(actual, isEmpty);
    });

    test('insert person', () async {
      final person = Person(null, 'Simon');
      await database.insertPerson(person);

      final actual = await database.findAllPersons();

      expect(actual, hasLength(1));
    });

    test('delete person', () async {
      final person = Person(1, 'Simon');
      await database.insertPerson(person);

      await database.deletePerson(person);

      final actual = await database.findAllPersons();
      expect(actual, isEmpty);
    });

    test('update person', () async {
      final person = Person(1, 'Simon');
      await database.insertPerson(person);
      final updatedPerson = Person(person.id, _reverse(person.name));

      await database.updatePerson(updatedPerson);

      final actual = await database.findPersonById(person.id);
      expect(actual, equals(updatedPerson));
    });

    test('insert persons', () async {
      final persons = [Person(1, 'Simon'), Person(2, 'Frank')];

      await database.insertPersons(persons);

      final actual = await database.findAllPersons();
      expect(actual, equals(persons));
    });

    test('delete persons', () async {
      final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
      await database.insertPersons(persons);

      await database.deletePersons(persons);

      final actual = await database.findAllPersons();
      expect(actual, isEmpty);
    });

    test('update persons', () async {
      final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
      await database.insertPersons(persons);
      final updatedPersons = persons
          .map((person) => Person(person.id, _reverse(person.name)))
          .toList();

      await database.updatePersons(updatedPersons);

      final actual = await database.findAllPersons();
      expect(actual, equals(updatedPersons));
    });

    test('replace persons in transaction', () async {
      final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
      await database.insertPersons(persons);
      final newPersons = [Person(3, 'Paul'), Person(4, 'Karl')];

      await database.replacePersons(newPersons);

      final actual = await database.findAllPersons();
      expect(actual, equals(newPersons));
    });

    test('insert person and return id of inserted item', () async {
      final person = Person(1, 'Simon');

      final actual = await database.insertPersonWithReturn(person);

      expect(actual, equals(person.id));
    });

    test('insert persons and return ids of inserted items', () async {
      final persons = [Person(1, 'Simon'), Person(2, 'Frank')];

      final actual = await database.insertPersonsWithReturn(persons);

      final expected = persons.map((person) => person.id).toList();
      expect(actual, equals(expected));
    });

    test('update person and return 1 (affected row count)', () async {
      final person = Person(1, 'Simon');
      await database.insertPerson(person);
      final updatedPerson = Person(person.id, _reverse(person.name));

      final actual = await database.updatePersonWithReturn(updatedPerson);

      final persistentPerson = await database.findPersonById(person.id);
      expect(persistentPerson, equals(updatedPerson));
      expect(actual, equals(1));
    });

    test('update persons and return affected rows count', () async {
      final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
      await database.insertPersons(persons);
      final updatedPersons = persons
          .map((person) => Person(person.id, _reverse(person.name)))
          .toList();

      final actual = await database.updatePersonsWithReturn(updatedPersons);

      final persistentPersons = await database.findAllPersons();
      expect(persistentPersons, equals(updatedPersons));
      expect(actual, equals(2));
    });
  });
}

String _reverse(String value) {
  return value.split('').reversed.join();
}
