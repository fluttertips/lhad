import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempsupabaseadmintool/core/supabase_client_service.dart';
import 'package:tempsupabaseadmintool/providers/auth_provider.dart';
import 'package:tempsupabaseadmintool/screens/login_screen.dart';
import 'package:tempsupabaseadmintool/theme/admin_tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Same Supabase project the rider app writes to.
  await SupabaseClientService.initialize(
    supabaseUrl: 'https://tfddqjqkbupfzbeybaqm.supabase.co',
    supabaseAnonKey: 'sb_publishable_KAG59NastVBjsJe9vkDWHA_otzbmPBT',
  );

  runApp(const LabHealthAdminApp());
}

class LabHealthAdminApp extends StatelessWidget {
  const LabHealthAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminAuthProvider(),
      child: MaterialApp(
        title: 'LabHealth Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AdminTokens.bg,
          colorScheme: ColorScheme.fromSeed(seedColor: AdminTokens.brand),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
