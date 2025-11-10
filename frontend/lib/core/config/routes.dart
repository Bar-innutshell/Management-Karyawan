import 'package:get/get.dart';
import '../../features/splash/screen/screen.dart';
import '../../features/auth/screen/screen.dart';
import '../../features/dashboard/screen/screen.dart';
import '../../features/admin_panel/screen/screen.dart';
import '../../features/employee/screen/screen.dart';
import '../../features/attendance/screen/screen.dart';
import '../../features/payroll/screen/screen.dart';

class Routes {
  static const splash = '/splash';
  static const auth = '/auth';
  static const dashboard = '/dashboard';
  static const adminDashboard = '/dashboard/admin';
  static const employeeDashboard = '/dashboard/employee';
  static const attendance = '/attendance';
  static const payroll = '/payroll';
}

class AppPages {
  static final pages = [
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.auth, page: () => const AuthScreen()),
    GetPage(name: Routes.dashboard, page: () => const DashboardScreen()),
    GetPage(name: Routes.adminDashboard, page: () => const AdminPanelScreen()),
    GetPage(name: Routes.employeeDashboard, page: () => const EmployeeScreen()),
    GetPage(name: Routes.attendance, page: () => const AttendanceScreen()),
    GetPage(name: Routes.payroll, page: () => const PayrollScreen()),
  ];
}
