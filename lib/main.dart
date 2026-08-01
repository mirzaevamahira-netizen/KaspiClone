import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const KaspiCloneApp());
}

class KaspiCloneApp extends StatefulWidget {
  const KaspiCloneApp({super.key});

  static _KaspiCloneAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_KaspiCloneAppState>();
  }

  @override
  State<KaspiCloneApp> createState() => _KaspiCloneAppState();
}

class _KaspiCloneAppState extends State<KaspiCloneApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = const Color(0xFFE31E24);

  void setTheme(ThemeMode mode) => setState(() => _themeMode = mode);
  void setColor(Color color) => setState(() => _primaryColor = color);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaspi Clone',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D2D2D),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      home: const DisclaimerScreen(),
    );
  }
}

// ==================== ДАННЫЕ ====================
class AppData {
  static Map<String, dynamic>? currentUser;
  static List<Map<String, dynamic>> shopItems = [
    {'name': 'iPhone 15 Pro', 'price': 450000, 'image': '📱'},
    {'name': 'AirPods Pro', 'price': 89990, 'image': '🎧'},
    {'name': 'MacBook Air M3', 'price': 620000, 'image': '💻'},
    {'name': 'Samsung Galaxy S25', 'price': 420000, 'image': '📱'},
  ];
  static List<Map<String, dynamic>> creditRequests = [];

  static String generateCardNumber() {
    final r = Random();
    return '4400 ${r.nextInt(9000) + 1000} ${r.nextInt(9000) + 1000} ${r.nextInt(9000) + 1000}';
  }

  static String generateIIN() => List.generate(12, (_) => Random().nextInt(10)).join();
}

// ==================== ДИСКЛЕЙМЕР ====================
class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 80, color: Color(0xFFE31E24)),
              const SizedBox(height: 24),
              const Text('⚠️ ВНИМАНИЕ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Text(
                  'Это приложение создано в развлекательных целях.\n\nНе является настоящим банковским приложением.\n\nЭто копия банка создана исключительно для эмоций и обучения.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: const Text('✅ Я ПОНИМАЮ И ПРИНИМАЮ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ВХОД ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE31E24), Color(0xFFC41A1F)])),
                child: const Column(
                  children: [
                    Text('Kaspi bank', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
                    SizedBox(height: 30),
                    Text('Добро пожаловать!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    if (_isRegistering) ...[
                      TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Имя в Kaspi', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Электронная почта', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Придумайте PIN (4 цифры)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Ваш номер телефона',
                        hintText: '+7 777 123 45 67',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isRegistering ? 'ЗАРЕГИСТРИРОВАТЬСЯ' : 'ПРОДОЛЖИТЬ'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _isRegistering = !_isRegistering),
                      child: Text(_isRegistering ? 'Уже есть аккаунт? Войти' : 'Нет аккаунта? Зарегистрироваться'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final users = jsonDecode(prefs.getString('users') ?? '[]');
    if (_isRegistering) {
      final newUser = {
        'phone': phone,
        'name': _nameController.text,
        'email': _emailController.text,
        'pin': _pinController.text,
        'balance': 0.0,
        'bonus': 0,
        'cardNumber': AppData.generateCardNumber(),
        'iin': AppData.generateIIN(),
        'role': phone == '+8880001488' ? 'owner' : 'user',
      };
      users.add(newUser);
      await prefs.setString('users', jsonEncode(users));
      AppData.currentUser = newUser;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const PinScreen()), (route) => false);
    } else {
      final user = (users as List).firstWhere((u) => u['phone'] == phone, orElse: () => {});
      if (user.isNotEmpty) {
        AppData.currentUser = user;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PinScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пользователь не найден')));
      }
    }
    setState(() => _isLoading = false);
  }
}

// ==================== PIN ====================
class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  void _checkBiometrics() async {
    try {
      final authenticated = await _auth.authenticate(localizedReason: 'Войдите по отпечатку пальца');
      if (authenticated && mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Введите PIN'), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          const Spacer(flex: 2),
          CircleAvatar(
            radius: 40,
            child: Text(
              AppData.currentUser?['name']?[0]?.toUpperCase() ?? '?',
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppData.currentUser?['name'] ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? const Color(0xFFE31E24) : Colors.transparent,
                  border: Border.all(color: i < _pin.length ? const Color(0xFFE31E24) : Colors.grey, width: 2),
                ),
              ),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((d) => _keyBtn(d)).toList(),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _checkBiometrics,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
                      child: const Icon(Icons.fingerprint, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 20),
                  _keyBtn('0'),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      if (_pin.isNotEmpty) {
                        setState(() => _pin = _pin.substring(0, _pin.length - 1));
                      }
                    },
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
                      child: const Icon(Icons.backspace, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _keyBtn(String d) {
    return GestureDetector(
      onTap: () {
        if (_pin.length < 4) {
          setState(() => _pin += d);
          if (_pin.length == 4) {
            if (_pin == AppData.currentUser?['pin']) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false);
            } else {
              setState(() => _pin = '');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверный PIN'), backgroundColor: Colors.red));
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: 65,
        height: 65,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!)),
        child: Center(child: Text(d, style: const TextStyle(fontSize: 24))),
      ),
    );
  }
}

// ==================== ГЛАВНЫЙ ЭКРАН ====================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late double _balance;
  late int _bonus;
  late String _cardNumber;
  late String _role;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = AppData.currentUser!;
    _balance = (user['balance'] as num?)?.toDouble() ?? 0;
    _bonus = user['bonus'] ?? 0;
    _cardNumber = user['cardNumber'] ?? AppData.generateCardNumber();
    _role = user['role'] ?? 'user';
    _transactions = [
      {'icon': '💰', 'title': 'Пополнение', 'amount': '+50 000 ₸', 'isIncome': true, 'date': 'Сегодня'},
      {'icon': '💸', 'title': 'Перевод', 'amount': '-12 500 ₸', 'isIncome': false, 'date': 'Вчера'},
      {'icon': '🛒', 'title': 'Магазин', 'amount': '-8 750 ₸', 'isIncome': false, 'date': '25 июля'}
    ];
  }

  void _updateBalance(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final users = jsonDecode(prefs.getString('users') ?? '[]');
    final index = (users as List).indexWhere((u) => u['phone'] == AppData.currentUser!['phone']);
    if (index != -1) {
      users[index]['balance'] = (users[index]['balance'] ?? 0) + amount;
      AppData.currentUser = users[index];
      await prefs.setString('users', jsonEncode(users));
      setState(() => _balance = users[index]['balance']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildDashboard()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFE31E24),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Магазин'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Банк'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // КАРТА
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF333333)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kaspi Gold', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
                   const Icon(Icons.credit_card, color: Colors.amber, size: 40),
                  ],
                ),
                const SizedBox(height: 20),
                Text(_cardNumber, style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 3)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Баланс', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${_balance.toStringAsFixed(0)} ₸', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Бонусы', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('🔥 $_bonus', style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // КНОПКИ
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickBtn('📤', 'Перевести', () => _showTransfer()),
                _quickBtn('📱', 'NFC', () => Navigator.push(context, MaterialPageRoute(builder: (context) => NFCTerminalScreen(onMoneyReceived: _updateBalance)))),
                _quickBtn('💳', 'Kaspi Tap', () => Navigator.push(context, MaterialPageRoute(builder: (context) => NFCCardScreen(balance: _balance, onTransfer: _updateBalance)))),
                _quickBtn(_role == 'owner' ? '👑' : _role == 'moderator' ? '🛡️' : '👤', 'Меню', () => _showRoleMenu(context, _role, _updateBalance)),
              ],
            ),
          ),
          // ИСТОРИЯ
          ..._transactions.map((t) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                  leading: Text(t['icon'] as String, style: const TextStyle(fontSize: 24)),
                  title: Text(t['title'] as String),
                  subtitle: Text(t['date'] as String),
                  trailing: Text(t['amount'] as String,
                      style: TextStyle(color: (t['isIncome'] as bool) ? Colors.green : Colors.red, fontWeight: FontWeight.bold))))),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _quickBtn(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showTransfer() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Перевод'),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final a = double.tryParse(ctrl.text) ?? 0;
              if (a > 0 && a <= _balance) {
                Navigator.pop(ctx);
                _updateBalance(-a);
              }
            },
            child: const Text('Перевести'),
          ),
        ],
      ),
    );
  }
}

// ==================== NFC ТЕРМИНАЛ ====================
class NFCTerminalScreen extends StatefulWidget {
  final Function(double) onMoneyReceived;
  const NFCTerminalScreen({super.key, required this.onMoneyReceived});

  @override
  State<NFCTerminalScreen> createState() => _NFCTerminalScreenState();
}

class _NFCTerminalScreenState extends State<NFCTerminalScreen> {
  String _status = 'Ожидание...';
  bool _isReading = false;

  @override
  void initState() {
    super.initState();
    _startNFC();
  }

  void _startNFC() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        final ndef = Ndef.from(tag);
        if (ndef != null) {
          final msg = await ndef.read();
          if (msg != null && msg.records.isNotEmpty) {
            final data = String.fromCharCodes(msg.records.first.payload);
            final parts = data.split('|');
            if (parts.length >= 3) {
              final name = parts[1];
              final amount = double.tryParse(parts[2]) ?? 0;
              setState(() {
                _status = '✅ +$amount ₸';
                _isReading = false;
              });
              widget.onMoneyReceived(amount);
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
                    title: const Text('✅ УСПЕШНО!'),
                    content: Text('+$amount ₸ от $name'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: const Text('ГОТОВО'),
                      ),
                    ],
                  ),
                );
              }
            }
          }
        }
      } catch (e) {}
    });
    setState(() {
      _status = '📱 Поднесите телефон';
      _isReading = true;
    });
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(title: const Text('Оплата NFC'), backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _isReading ? const Color(0xFFE31E24) : Colors.grey, width: 3),
              ),
              child: Center(child: Icon(Icons.nfc, size: 80, color: _isReading ? const Color(0xFFE31E24) : Colors.grey)),
            ),
            const SizedBox(height: 40),
            Text(_status, style: TextStyle(fontSize: 18, color: _status.contains('✅') ? Colors.green : Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ==================== NFC КАРТА ====================
class NFCCardScreen extends StatefulWidget {
  final double balance;
  final Function(double) onTransfer;
  const NFCCardScreen({super.key, required this.balance, required this.onTransfer});

  @override
  State<NFCCardScreen> createState() => _NFCCardScreenState();
}

class _NFCCardScreenState extends State<NFCCardScreen> {
  final _amountCtrl = TextEditingController();
  bool _isReady = false;

  void _send() async {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0 || amount > widget.balance) return;
    setState(() => _isReady = true);
    try {
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);
        if (ndef != null) {
          final data = '${AppData.currentUser!['phone']}|${AppData.currentUser!['name']}|${amount.toInt()}';
          await ndef.write(NdefMessage([NdefRecord.createText(data)]));
          widget.onTransfer(-amount);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ${amount.toInt()} ₸ отправлено!'), backgroundColor: Colors.green));
            Navigator.pop(context);
          }
        }
      });
    } catch (e) {
      setState(() => _isReady = false);
    }
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(title: const Text('Kaspi Tap'), backgroundColor: Colors.transparent),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isReady ? const Color(0xFFE31E24).withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  border: Border.all(color: _isReady ? const Color(0xFFE31E24) : Colors.grey, width: 3),
                ),
                child: Center(child: Icon(Icons.credit_card, size: 80, color: _isReady ? const Color(0xFFE31E24) : Colors.grey)),
              ),
              const SizedBox(height: 40),
              if (!_isReady) ...[
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 32),
                    border: InputBorder.none,
                    suffixText: '₸',
                    suffixStyle: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [1000, 5000, 10000]
                      .map((a) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton(
                              onPressed: () => _amountCtrl.text = a.toString(),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.grey)),
                              child: Text('$a ₸'))))
                      .toList(),
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(onPressed: _isReady ? null : _send, child: Text(_isReady ? 'ОЖИДАНИЕ...' : 'ОТПРАВИТЬ')),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ПРОФИЛЬ ====================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppData.currentUser!;
    final role = user['role'] ?? 'user';
    String roleEmoji = '👤';
    String roleName = 'User';
    if (role == 'owner') {
      roleEmoji = '👑';
      roleName = 'Owner';
    }
    if (role == 'moderator') {
      roleEmoji = '🛡️';
      roleName = 'Moderator';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFE31E24),
              child: Text(user['name'][0].toUpperCase(), style: const TextStyle(fontSize: 40, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Text(user['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('$roleEmoji $roleName', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow('📱', 'Номер', user['phone']),
                    const Divider(),
                    _infoRow('📧', 'Почта', user['email'] ?? '-'),
                    const Divider(),
                    _infoRow('🪪', 'ИИН', user['iin'] ?? '-'),
                    const Divider(),
                    _infoRow('💳', 'Карта', user['cardNumber'] ?? '-'),
                    const Divider(),
                    _infoRow('💰', 'Баланс', '${user['balance']} ₸'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.color_lens, color: Color(0xFFE31E24)),
                    title: const Text('Тема оформления'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemePicker(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Color(0xFFE31E24)),
                    title: const Text('Сменить PIN'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _changePin(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info, color: Color(0xFFE31E24)),
                    title: const Text('О приложении'),
                    subtitle: const Text('v2.0'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  AppData.currentUser = null;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('🚪 ВЫЙТИ', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

// ==================== GLOBAL HELPER FUNCTIONS ====================

void _showThemePicker(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('🎨 Выбор темы'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
            ),
            title: const Text('Светлая'),
            onTap: () {
              Navigator.pop(ctx);
              KaspiCloneApp.of(context)?.setTheme(ThemeMode.light);
              KaspiCloneApp.of(context)?.setColor(const Color(0xFFE31E24));
            },
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
            ),
            title: const Text('Тёмная'),
            onTap: () {
              Navigator.pop(ctx);
              KaspiCloneApp.of(context)?.setTheme(ThemeMode.dark);
            },
          ),
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFE31E24), borderRadius: BorderRadius.circular(8))),
            title: const Text('Красная'),
            onTap: () {
              Navigator.pop(ctx);
              KaspiCloneApp.of(context)?.setTheme(ThemeMode.light);
              KaspiCloneApp.of(context)?.setColor(const Color(0xFFE31E24));
            },
          ),
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(8))),
            title: const Text('Синяя'),
            onTap: () {
              Navigator.pop(ctx);
              KaspiCloneApp.of(context)?.setTheme(ThemeMode.light);
              KaspiCloneApp.of(context)?.setColor(const Color(0xFF2196F3));
            },
          ),
        ],
      ),
    ),
  );
}

void _changePin(BuildContext context) {
  final oldCtrl = TextEditingController(), newCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Сменить PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldCtrl,
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Старый PIN', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newCtrl,
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Новый PIN', border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        ElevatedButton(
          onPressed: () async {
            if (oldCtrl.text == AppData.currentUser!['pin'] && newCtrl.text.length == 4) {
              final prefs = await SharedPreferences.getInstance();
              final users = jsonDecode(prefs.getString('users') ?? '[]');
              final idx = (users as List).indexWhere((u) => u['phone'] == AppData.currentUser!['phone']);
              if (idx != -1) {
                users[idx]['pin'] = newCtrl.text;
                AppData.currentUser = users[idx];
                await prefs.setString('users', jsonEncode(users));
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ PIN изменён!'), backgroundColor: Colors.green));
            }
          },
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
}

void _showAbout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Kaspi Clone v2.0'),
      content: const Text(
          'Приложение создано в развлекательных целях.\n\nФункции:\n• NFC переводы (Kaspi Tap)\n• QR сканер\n• Магазин\n• Кредиты\n• Система ролей\n• Тёмная тема\n\nНе является настоящим банком!'),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
      ],
    ),
  );
}

void _showRoleMenu(BuildContext context, String _role, Function(double) _updateBalance) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(_role == 'owner' ? '👑 Admin' : _role == 'moderator' ? '🛡️ Moder' : '👤 User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_role == 'owner' || _role == 'moderator')
            ListTile(
              leading: const Text('➕'),
              title: const Text('Добавить товар'),
              onTap: () {
                Navigator.pop(ctx);
                _addItem(context);
              },
            ),
          if (_role == 'owner') ...[
            ListTile(
              leading: const Text('👥'),
              title: const Text('Пользователи'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('💰'),
              title: const Text('Выдача денег'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
          ListTile(
            leading: const Text('🎁'),
            title: const Text('Бонус 1000 ₸'),
            onTap: () {
              Navigator.pop(ctx);
              _updateBalance(1000);
            },
          ),
        ],
      ),
    ),
  );
}

void _addItem(BuildContext context) {
  final n = TextEditingController(), p = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Добавить товар'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: n, decoration: const InputDecoration(labelText: 'Название')),
          TextField(controller: p, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Цена')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        ElevatedButton(
          onPressed: () {
            final price = double.tryParse(p.text) ?? 0;
            if (n.text.isNotEmpty && price > 0) {
              // В настоящем приложении здесь была бы логика добавления товара
              Navigator.pop(ctx);
            }
          },
          child: const Text('Добавить'),
        ),
      ],
    ),
  );
}
