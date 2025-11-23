import 'package:delivery_app/business_logic/cubits/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/admin_repository.dart';
import 'data/repositories/delivery_boy_repository.dart';
import 'data/repositories/customer_repository.dart';
import 'business_logic/cubits/auth/auth_cubit.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/admin/admin_dashboard.dart';
import 'presentation/screens/delivery_boy/delivery_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final apiService = ApiService(storageService);
  
  runApp(MyApp(
    storageService: storageService,
    apiService: apiService,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;

  const MyApp({
    Key? key,
    required this.storageService,
    required this.apiService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(apiService, storageService),
        ),
        RepositoryProvider(
          create: (context) => AdminRepository(apiService),
        ),
        RepositoryProvider(
          create: (context) => DeliveryBoyRepository(apiService),
        ),
        RepositoryProvider(
          create: (context) => CustomerRepository(apiService),
        ),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(
          context.read<AuthRepository>(),
        )..checkAuthStatus(),
        child: MaterialApp(
          title: 'Delivery Management',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: AppColors.background,
            textTheme: GoogleFonts.poppinsTextTheme(),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.primary,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (state is AuthAuthenticated) {
                if (state.user.role == 'admin') {
                  return const AdminDashboard();
                } else {
                  return const DeliveryDashboard();
                }
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}