import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  bool _create = false;
  bool _showPassword = false;
  bool _busy = false;
  String? _error;
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      if (_create) {
        final username = _username.text.trim();
        final response = await _supabase.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          data: {'username': username, 'display_name': username},
        );
        if (!mounted) return;
        if (response.session == null) {
          setState(() => _error = 'تم إنشاء الحساب. إذا وصلك إيميل تفعيل، فعّل حسابك ثم ارجع وسجّل الدخول.');
        }
      } else {
        await _supabase.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _friendlyAuthError(e.message));
    } catch (e) {
      if (mounted) setState(() => _error = 'تعذّر الاتصال بالمصادقة. تأكد من إعدادات Supabase والإنترنت.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials')) return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    if (m.contains('user already registered')) return 'هذا البريد مسجّل مسبقاً. جرّب تسجيل الدخول.';
    if (m.contains('password')) return 'كلمة المرور غير مقبولة. استخدم 6 أحرف أو أكثر.';
    if (m.contains('email not confirmed')) return 'فعّل بريدك الإلكتروني أولاً ثم سجّل الدخول.';
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB9E5A2),
                Color(0xFFF8F0D8),
                Color(0xFFDFC08A),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Card(
                    elevation: 12,
                    color: const Color(0xFFFFF9E9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                        color: Color(0xFF98602F),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🌾 🏡 🌻',
                              style: TextStyle(fontSize: 48),
                            ),
                            const Text(
                              'مزرعتي',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF75401D),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _create
                                  ? 'أنشئ حسابك وابدأ مزرعتك'
                                  : 'أهلاً بعودتك إلى مزرعتك',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 22),
                            if (_create) ...[
                              TextFormField(
                                controller: _username,
                                textDirection: TextDirection.ltr,
                                decoration: const InputDecoration(
                                  labelText: 'اسم المستخدم',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  final username = (value ?? '').trim();
                                  if (!_create) return null;
                                  if (username.length < 3 || username.length > 20) {
                                    return 'اسم المستخدم من 3 إلى 20 حرفاً';
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
                                    return 'استخدم الإنجليزية والأرقام و _ فقط';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  (value == null ||
                                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                          .hasMatch(value.trim()))
                                  ? 'أدخل بريداً إلكترونياً صحيحاً'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              obscureText: !_showPassword,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => _showPassword = !_showPassword,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  (value == null || value.length < 6)
                                  ? 'كلمة المرور لازم تكون 6 أحرف على الأقل'
                                  : null,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE6D9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFF8A2E15),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: _busy ? null : _submit,
                                icon: _busy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.agriculture),
                                label: Text(
                                  _busy
                                      ? 'لحظة...'
                                      : (_create
                                            ? 'إنشاء حساب جديد'
                                            : 'تسجيل الدخول'),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF347A3F),
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => setState(() {
                                      _create = !_create;
                                      _error = null;
                                    }),
                              child: Text(
                                _create
                                    ? 'عندي حساب — تسجيل الدخول'
                                    : 'ما عندي حساب — إنشاء حساب',
                              ),
                            ),
                            const Text(
                              'حسابك ومزرعتك يرتبطان بتسجيل الدخول الحقيقي.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
