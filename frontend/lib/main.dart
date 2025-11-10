import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/config/routes.dart';
import 'core/config/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storageService = StorageService();
  Get.put(storageService);

  final apiService = ApiService(storage: storageService);
  Get.put(apiService);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Manajemen Karyawan',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
