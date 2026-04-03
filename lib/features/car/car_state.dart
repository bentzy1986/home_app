import 'package:flutter/material.dart';
import 'models/car_models.dart';

class CarState extends ChangeNotifier {
  final List<CarModel> cars = [
    CarModel(
      id: 'c1',
      nickname: 'יונדאי משפחתית',
      plate: '12-345-67',
      brand: 'Hyundai',
      model: 'Tucson',
      year: 2020,
      fuelType: FuelType.petrol95,
      currentMileage: 45000,
      documents: [
        CarDocument(
          id: 'd1',
          title: 'טסט שנתי',
          expiryDate: DateTime(2026, 8, 15),
          icon: Icons.fact_check_rounded,
          color: Colors.orange,
        ),
        CarDocument(
          id: 'd2',
          title: 'רישיון רכב',
          expiryDate: DateTime(2026, 8, 15),
          icon: Icons.assignment_rounded,
          color: Colors.blue,
        ),
        CarDocument(
          id: 'd3',
          title: 'ביטוח חובה',
          expiryDate: DateTime(2027, 1, 1),
          icon: Icons.security_rounded,
          color: Colors.green,
        ),
        CarDocument(
          id: 'd4',
          title: 'ביטוח מקיף',
          expiryDate: DateTime(2027, 1, 1),
          icon: Icons.shield_rounded,
          color: Colors.teal,
        ),
      ],
      serviceHistory: [
        ServiceRecord(
          id: 's1',
          title: 'טיפול 45,000',
          type: ServiceType.oilChange,
          date: DateTime(2026, 2, 10),
          cost: 850,
          mileage: 45000,
          garage: 'מוסך המרכז',
        ),
        ServiceRecord(
          id: 's2',
          title: 'החלפת צמיגים קדמיים',
          type: ServiceType.tires,
          date: DateTime(2025, 11, 5),
          cost: 1200,
          mileage: 42000,
          garage: 'צמיגי העיר',
        ),
      ],
      reminders: [
        ServiceReminder(
          id: 'r1',
          title: 'טיפול 50,000',
          type: ServiceType.oilChange,
          dueDate: DateTime(2026, 8, 1),
          dueMileage: 50000,
        ),
      ],
    ),
    CarModel(
      id: 'c2',
      nickname: 'קיה פיקנטו',
      plate: '99-888-77',
      brand: 'Kia',
      model: 'Picanto',
      year: 2019,
      fuelType: FuelType.petrol95,
      currentMileage: 62000,
      documents: [
        CarDocument(
          id: 'd5',
          title: 'טסט שנתי',
          expiryDate: DateTime(2026, 11, 20),
          icon: Icons.fact_check_rounded,
          color: Colors.orange,
        ),
        CarDocument(
          id: 'd6',
          title: 'ביטוח חובה',
          expiryDate: DateTime(2026, 5, 10),
          icon: Icons.security_rounded,
          color: Colors.green,
        ),
        CarDocument(
          id: 'd7',
          title: 'ביטוח מקיף',
          expiryDate: DateTime(2026, 5, 10),
          icon: Icons.shield_rounded,
          color: Colors.teal,
        ),
      ],
      serviceHistory: [
        ServiceRecord(
          id: 's3',
          title: 'החלפת מצבר',
          type: ServiceType.battery,
          date: DateTime(2025, 8, 20),
          cost: 650,
          mileage: 60000,
          garage: 'חשמלאי רכב',
        ),
      ],
      reminders: [
        ServiceReminder(
          id: 'r2',
          title: 'טיפול 65,000',
          type: ServiceType.oilChange,
          dueDate: DateTime(2026, 6, 1),
          dueMileage: 65000,
        ),
      ],
    ),
  ];

  int _currentIndex = 0;

  CarModel get currentCar => cars[_currentIndex];
  int get currentIndex => _currentIndex;

  void switchCar(int index) {
    if (index >= 0 && index < cars.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void addCar(CarModel car) {
    cars.add(car);
    notifyListeners();
  }

  void updateCar(CarModel updated) {
    final i = cars.indexWhere((c) => c.id == updated.id);
    if (i != -1) {
      cars[i] = updated;
      notifyListeners();
    }
  }

  void deleteCar(String id) {
    cars.removeWhere((c) => c.id == id);
    if (_currentIndex >= cars.length) _currentIndex = cars.length - 1;
    notifyListeners();
  }

  void addServiceRecord(String carId, ServiceRecord record) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.serviceHistory.insert(0, record);
    notifyListeners();
  }

  void deleteServiceRecord(String carId, String recordId) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.serviceHistory.removeWhere((s) => s.id == recordId);
    notifyListeners();
  }

  void addReminder(String carId, ServiceReminder reminder) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.reminders.add(reminder);
    notifyListeners();
  }

  void toggleReminder(String carId, String reminderId) {
    final car = cars.firstWhere((c) => c.id == carId);
    final reminder = car.reminders.firstWhere((r) => r.id == reminderId);
    reminder.isDone = !reminder.isDone;
    notifyListeners();
  }

  void deleteReminder(String carId, String reminderId) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.reminders.removeWhere((r) => r.id == reminderId);
    notifyListeners();
  }

  void updateDocument(String carId, CarDocument updated) {
    final car = cars.firstWhere((c) => c.id == carId);
    final i = car.documents.indexWhere((d) => d.id == updated.id);
    if (i != -1) {
      car.documents[i] = updated;
      notifyListeners();
    }
  }

  void updateMileage(String carId, int mileage) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.currentMileage = mileage;
    notifyListeners();
  }

  // כל התזכורות הדחופות מכל הרכבים
  List<Map<String, dynamic>> get allUrgentReminders {
    final result = <Map<String, dynamic>>[];
    for (final car in cars) {
      for (final r in car.activeReminders) {
        if (r.isUrgent || r.isOverdue) {
          result.add({'car': car, 'reminder': r});
        }
      }
    }
    return result;
  }

  // כל המסמכים הדחופים מכל הרכבים
  List<Map<String, dynamic>> get allUrgentDocuments {
    final result = <Map<String, dynamic>>[];
    for (final car in cars) {
      for (final d in car.urgentDocuments) {
        result.add({'car': car, 'document': d});
      }
    }
    return result;
  }
}
