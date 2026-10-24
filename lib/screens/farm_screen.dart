import 'package:flutter/material.dart';
import '../models/catalog.dart';
import 'login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});
  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  int _tab = 0;
  int _coins = 0;
  int _level = 1;
  String _playerName = 'مزارع';
  bool _loadingProfile = true;
  final Map<String, int> _inventory = {};
  final Set<String> _ownedAnimals = {};
  final Set<String> _ownedTools = {};
  String _notice = 'أهلاً بك بمزرعتك!';

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('username, display_name, level, dinar')
          .eq('id', user.id)
          .single();
      if (!mounted) return;
      setState(() {
        _playerName = (profile['display_name'] as String?)?.isNotEmpty == true
            ? profile['display_name'] as String
            : (profile['username'] as String? ?? 'مزارع');
        _level = (profile['level'] as num?)?.toInt() ?? 1;
        _coins = (profile['dinar'] as num?)?.toInt() ?? 0;
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingProfile = false;
        _notice = 'تعذّر تحميل ملف اللاعب. تأكد من تشغيل مخطط قاعدة البيانات في Supabase.';
      });
    }
  }

  void _buySeed(SeedItem item) {
    if (_level < item.level) {
      setState(() => _notice = 'تحتاج المستوى ${item.level} لفتح ${item.name}');
      return;
    }
    if (_coins < item.price) {
      setState(() => _notice = 'رصيدك غير كافٍ لشراء ${item.name}');
      return;
    }
    setState(() {
      _coins -= item.price;
      _inventory[item.name] = (_inventory[item.name] ?? 0) + 1;
      _notice = 'تم شراء بذور ${item.name} تجريبياً';
    });
  }

  void _buyAnimal(AnimalItem item) {
    if (_coins < item.price) {
      setState(() => _notice = 'رصيدك غير كافٍ');
      return;
    }
    setState(() {
      _coins -= item.price;
      _ownedAnimals.add(item.name);
      _notice = 'تم شراء ${item.name} تجريبياً';
    });
  }

  void _buyTool(ToolItem item) {
    setState(() {
      _ownedTools.add(item.name);
      _notice = 'تمت إضافة ${item.name} للملكية التجريبية. ربط عملة الأدوات بالخادم مطلوب.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _farmPage(),
      _shopPage(),
      _animalsPage(),
      _inventoryPage(),
      _friendsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌿 مزرعتي'),
        actions: [
          IconButton(
            tooltip: 'الحساب',
            onPressed: () async { await Supabase.instance.client.auth.signOut(); },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(children: [
        if (_loadingProfile) const LinearProgressIndicator(minHeight: 3),
        _topStats(),
        Expanded(child: pages[_tab]),
        Container(
          width: double.infinity,
          color: const Color(0xFFE4F0D5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(_notice, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        )
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.agriculture), label: 'المزرعة'),
          NavigationDestination(icon: Icon(Icons.storefront), label: 'المتجر'),
          NavigationDestination(icon: Icon(Icons.pets), label: 'الحيوانات'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'المخزن'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'الأصدقاء'),
        ],
      ),
    );
  }

  Widget _topStats() => Container(
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF28683B), Color(0xFF55A65C)]),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))],
    ),
    child: Row(children: [
      const CircleAvatar(backgroundColor: Colors.white, child: Text('🌱', style: TextStyle(fontSize: 24))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_playerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        Text('المستوى $_level', style: const TextStyle(color: Colors.white70)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('الرصيد', style: TextStyle(color: Colors.white70)),
        Text(formatDinar(_coins), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    ]),
  );

  Widget _farmPage() => ListView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), children: [
    Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFBFE9A7), Color(0xFF6BAA55)]),
      ),
      child: Stack(children: [
        const Positioned(top: 18, right: 18, child: Text('☀️', style: TextStyle(fontSize: 35))),
        const Center(child: Text('🏡   🌳   🐄\n\n🌾  🥕  🌽  🍅', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, height: 1.45))),
        Positioned(bottom: 10, left: 12, child: Chip(label: Text('مزرعتك • المستوى $_level'))),
      ]),
    ),
    const SizedBox(height: 14),
    Row(children: [
      Expanded(child: _actionCard('🌾', 'احصد المحاصيل', 'اجمع محاصيلك', () {
        final count = _inventory.values.fold<int>(0, (a, b) => a + b);
        setState(() {
          _coins += count * 1500;
          _level = (_level + (count > 0 ? 1 : 0)).clamp(1, 120);
          _inventory.clear();
          _notice = count > 0 ? 'حصاد تجريبي! أضيفت ${formatDinar(count * 1500)}' : 'ما عندك محاصيل جاهزة للحصاد';
        });
      })),
      const SizedBox(width: 10),
      Expanded(child: _actionCard('🧑‍🌾', 'زيارة الأصدقاء', 'شاهد المزارع', () => setState(() { _tab = 4; _notice = 'قائمة الأصدقاء تحتاج ربط الخادم.'; }))),
    ]),
    const SizedBox(height: 14),
    const Text('مهام اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    _tile('📜', 'ازرع محصولاً', 'ابدأ من متجر البذور'),
    _tile('🐓', 'اعتنِ بالحيوانات', 'اجمع منتجات حيواناتك'),
  ]);

  Widget _shopPage() => ListView(padding: const EdgeInsets.all(12), children: [
    const Text('متجر البذور', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const Text('الأسعار بالدينار العراقي • الأسعار والمستويات حسب القائمة'),
    const SizedBox(height: 8),
    ...seeds.map((s) => Card(child: ListTile(
      leading: Text(s.emoji, style: const TextStyle(fontSize: 30)),
      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${formatDinar(s.price)} • المستوى ${s.level}'),
      trailing: FilledButton(onPressed: () => _buySeed(s), child: const Text('شراء')),
    ))),
    const SizedBox(height: 10),
    const Text('الأدوات', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    ...tools.map((t) => Card(child: ListTile(
      leading: Text(t.emoji, style: const TextStyle(fontSize: 28)),
      title: Text(t.name),
      subtitle: Text('${t.price} عملة • ${t.description}'),
      trailing: IconButton(onPressed: () => _buyTool(t), icon: const Icon(Icons.add_shopping_cart)),
    ))),
  ]);

  Widget _animalsPage() => ListView(padding: const EdgeInsets.all(12), children: [
    const Text('متجر الحيوانات', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const Text('الحيوانات الإنتاجية والأليفة'),
    ...animals.map((a) => Card(child: ListTile(
      leading: Text(a.emoji, style: const TextStyle(fontSize: 30)),
      title: Text(a.name),
      subtitle: Text('${formatDinar(a.price)} • ${a.productive ? 'إنتاجي' : 'أليف'}${_ownedAnimals.contains(a.name) ? ' • تملكه' : ''}'),
      trailing: FilledButton(onPressed: () => _buyAnimal(a), child: const Text('شراء')),
    ))),
  ]);

  Widget _inventoryPage() => ListView(padding: const EdgeInsets.all(12), children: [
    const Text('المخزن', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    if (_inventory.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('المخزن فارغ حالياً. اشترِ بذوراً من المتجر.'))),
    ..._inventory.entries.map((e) => Card(child: ListTile(leading: const Text('🌱', style: TextStyle(fontSize: 28)), title: Text(e.key), trailing: Text('× ${e.value}')))),
    const SizedBox(height: 12),
    const Text('أدواتك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ..._ownedTools.map((t) => _tile('🛠️', t, 'أداة مملوكة')),
  ]);

  Widget _friendsPage() => ListView(padding: const EdgeInsets.all(12), children: [
    const Text('الأصدقاء والمنافسة', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    _tile('👥', 'إضافة صديق', 'البحث باسم المستخدم — يحتاج خادم'),
    _tile('🏡', 'زيارة مزرعة', 'زيارة مزرعة صديق — يحتاج خادم'),
    _tile('🏆', 'لوحة المتصدرين', 'ترتيب اللاعبين حسب المستوى والثروة'),
    const SizedBox(height: 10),
    OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), icon: const Icon(Icons.login), label: const Text('تسجيل الدخول للمزامنة الجماعية')),
  ]);

  Widget _actionCard(String emoji, String title, String subtitle, VoidCallback onTap) => Card(
    elevation: 2,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 6),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ])),
    ),
  );

  Widget _tile(String emoji, String title, String subtitle) => Card(child: ListTile(leading: Text(emoji, style: const TextStyle(fontSize: 26)), title: Text(title), subtitle: Text(subtitle)));
}
