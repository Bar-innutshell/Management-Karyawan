import 'package:get/get.dart';
import '../../features/splash/screen/screen.dart';
import '../../features/auth/screen/screen.dart';
import '../../features/dashboard/screen/screen.dart';
import '../../features/admin_panel/screen/screen.dart';
import '../../features/employee/screen/screen.dart';
import '../../features/attendance/screen/screen.dart';
import '../../features/payroll/screen/screen.dart';
import '../../features/payroll/screen/salary_info_screen.dart';
import '../../features/payroll/screen/salary_detail_screen.dart';
import '../../features/admin_panel/screen/register_user_screen.dart';
import '../../features/reporting/screen/admin_screen.dart';

class Routes {
  static const splash = '/splash';
  static const auth = '/auth';
  static const dashboard = '/dashboard';
  static const adminDashboard = '/dashboard/admin';
  static const employeeDashboard = '/dashboard/employee';
  static const attendance = '/attendance';
  static const payroll = '/payroll';
  static const salaryInfo = '/admin/dashboard/informasi-gaji';
  static const salaryDetail = '/admin/dashboard/informasi-gaji/detail';
  static const registerUser = '/admin/dashboard/register-user';
  static const adminReport = '/admin/dashboard/laporan';
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
    GetPage(name: Routes.salaryInfo, page: () => const SalaryInfoScreen()),
    GetPage(name: Routes.salaryDetail, page: () => const SalaryDetailScreen()),
    GetPage(name: Routes.registerUser, page: () => const RegisterUserScreen()),
    GetPage(name: Routes.adminReport, page: () => const AdminReportScreen()),
  ];
}
