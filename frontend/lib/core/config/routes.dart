import 'package:get/get.dart';

// ===== Import Semua Screen =====
import '../../features/splash/screen/screen.dart';
import '../../features/auth/screen/screen.dart';
import '../../features/dashboard/screen/screen.dart';
import '../../features/admin_panel/screen/screen.dart';
import '../../features/manage-payroll/screen/screen.dart';
import '../../features/manage-report/screen/screen.dart';
import '../../features/manage-schedule/screen/screen.dart';
import '../../features/manage-users/screen/screen.dart';
import '../../features/employee/screen/screen.dart';
import '../../features/cashier/screen/screen.dart'; // <-- import CashierScreen
import '../../features/schedule/screen/screen.dart';
import '../../features/payroll/screen/screen.dart';
import '../../features/reporting/screen/screen.dart';
import '../../features/attendance/screen/screen.dart';

// ===== Definisi Nama Routes =====
class Routes {
  static const splash = '/splash';
  static const auth = '/auth';
  static const dashboard = '/dashboard';

  // Admin & Employee Dashboard
  static const adminDashboard = '/dashboard/admin';
  static const employeeDashboard = '/dashboard/employee';
  static const cashierDashboard = '/dashboard/cashier'; // <-- route baru

  // Admin Sub-pages (nested under /dashboard/admin)
  static const manageUser = '$adminDashboard/manage-user';
  static const manageSchedule = '$adminDashboard/manage-schedule';
  static const managePayroll = '$adminDashboard/manage-payroll';
  static const manageReport = '$adminDashboard/manage-report';

  // Employee Sub-pages
  static const schedule = '$employeeDashboard/schedule';
  static const attendance = '$employeeDashboard/attendance';
  static const payroll = '$employeeDashboard/payroll';
  static const reporting = '$employeeDashboard/reporting';
}

// ===== Definisi Halaman untuk Setiap Route =====
class AppPages {
  static final pages = [
    // Halaman utama
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.auth, page: () => const AuthScreen()),
    GetPage(name: Routes.dashboard, page: () => const DashboardScreen()),

    // Dashboard
    GetPage(name: Routes.adminDashboard, page: () => const AdminPanelScreen()),
    GetPage(name: Routes.employeeDashboard, page: () => const EmployeeScreen()),
    GetPage(
      name: Routes.cashierDashboard,
      page: () => const CashierScreen(),
    ), // <-- GetPage baru
    // Halaman turunan Admin (nested)
    GetPage(name: Routes.manageUser, page: () => const ManageUserScreen()),
    GetPage(
      name: Routes.manageSchedule,
      page: () => const ManageScheduleScreen(),
    ),
    GetPage(
      name: Routes.managePayroll,
      page: () => const ManagePayrollScreen(),
    ),
    GetPage(name: Routes.manageReport, page: () => const ManageReportScreen()),

    // Halaman turunan Employee / minimal Hello World
    GetPage(name: Routes.schedule, page: () => const ScheduleScreen()),
    GetPage(name: Routes.payroll, page: () => const PayrollScreen()),
    GetPage(name: Routes.reporting, page: () => const ReportingScreen()),
    GetPage(name: Routes.attendance, page: () => const AttendanceScreen()),
  ];
}
