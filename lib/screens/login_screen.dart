import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  bool _create = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  void _unconfigured() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('المصادقة غير مربوطة بعد. أضف إعدادات Supabase أولاً.')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('حساب مزرعتي')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      const SizedBox(height: 20),
      const Center(child: Text('🌿', style: TextStyle(fontSize: 70))),
      const Center(child: Text('أهلاً بك بمزرعتي', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      const SizedBox(height: 8),
      Center(child: Text(_create ? 'أنشئ حسابك وابدأ مزرعتك' : 'سجّل الدخول لمتابعة تقدمك')),
      const SizedBox(height: 24),
      if (_create) TextField(controller: _username, decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
      if (_create) const SizedBox(height: 12),
      TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email), border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _password, obscureText: !_showPassword, decoration: InputDecoration(labelText: 'كلمة المرور', prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPassword = !_showPassword)))),
      const SizedBox(height: 18),
      FilledButton(onPressed: _unconfigured, child: Text(_create ? 'إنشاء حساب' : 'تسجيل الدخول')),
      OutlinedButton.icon(onPressed: _unconfigured, icon: const Icon(Icons.g_mobiledata, size: 30), label: const Text('المتابعة باستخدام Google')),
      TextButton(onPressed: () => setState(() => _create = !_create), child: Text(_create ? 'عندي حساب بالفعل' : 'إنشاء حساب جديد')),
      const SizedBox(height: 12),
      const Text('هذه واجهة أولية. ربط المصادقة يحتاج إعداد مشروع Supabase وGoogle OAuth.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
    ]),
  );
}
