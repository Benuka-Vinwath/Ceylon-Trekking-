import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../shell/main_shell.dart';

void _go(BuildContext context, Widget screen) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
}

// Runs a login/signup call; on success opens the app, on failure shows the server's message.
Future<void> _submit(BuildContext context, Future<void> Function() call) async {
  try {
    await call();
    if (context.mounted) goToMain(context);
  } on ApiException catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
  }
}

// ───────── Splash ─────────
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F2B21), Color(0xFF2E7D5B)]),
        ),
        child: Stack(
          children: [
            Positioned(left: 0, right: 0, bottom: 0, height: h * .5, child: const CustomPaint(painter: MountainPainter())),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle),
                      child: const Icon(Icons.terrain, size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    const Text('Ceylon Trekking', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    const Text('Explore Sri Lanka.\nTrek Beyond the Ordinary.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFFCFE6DA), height: 1.5)),
                    const Spacer(flex: 3),
                    AppButton(label: 'Get Started', style: BtnStyle.white, onTap: () => _go(context, const OnboardingScreen())),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _go(context, const LoginScreen()),
                      child: const Text('I already have an account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────── Onboarding ─────────
class _ObData {
  final IconData icon;
  final String title, body;
  final List<Color> colors;
  const _ObData(this.icon, this.title, this.body, this.colors);
}

const _obPages = [
  _ObData(Icons.landscape, "Discover Sri Lanka's\nbest treks", 'Browse trails with distance, difficulty, elevation, safety tips and honest reviews from fellow trekkers.', [Color(0xFF7FB99A), Color(0xFF2E7D5B)]),
  _ObData(Icons.wifi_off, 'Navigate even\nwithout signal', 'Download trek maps before you go. GPS keeps tracking you on the trail, no internet needed.', [Color(0xFFF2C27A), Color(0xFFC9792B)]),
  _ObData(Icons.local_parking, 'Park smart, gear up\nlocally', 'Find trailhead parking and nearby gear rental shops so you arrive prepared.', [Color(0xFF8DB7D9), Color(0xFF2F6F9F)]),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _go(context, const LoginScreen());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _obPages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => _ObPage(data: _obPages[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final on = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: on ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(color: on ? AppColors.primary : const Color(0xFFCBD5CF), borderRadius: BorderRadius.circular(4)),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  AppButton(label: _page < 2 ? 'Next' : 'Get Started', onTap: _next),
                  SizedBox(
                    height: 44,
                    child: _page < 2
                        ? TextButton(onPressed: () => _go(context, const LoginScreen()), child: const Text('Skip', style: TextStyle(color: AppColors.muted)))
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ObPage extends StatelessWidget {
  final _ObData data;
  const _ObPage({required this.data});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cs) {
      final h = cs.maxHeight;
      return Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: h * .58,
            child: MountainScene(
              colors: data.colors,
              child: Align(
                alignment: const Alignment(0, -0.25),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
                  child: Icon(data.icon, size: 56, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            top: h * .5,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25)),
                  const SizedBox(height: 14),
                  Text(data.body, style: const TextStyle(fontSize: 15, color: AppColors.muted, height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ───────── Login ─────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackCircle(bg: AppColors.bg, onTap: () => _go(context, const OnboardingScreen())),
              const SizedBox(height: 28),
              const Text('Welcome back 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Log in to continue your trekking journey.', style: TextStyle(fontSize: 15, color: AppColors.muted)),
              const SizedBox(height: 28),
              AppField(label: 'Email', hint: 'you@example.com', controller: _email),
              const SizedBox(height: 18),
              AppField(label: 'Password', hint: '••••••••', obscure: true, controller: _password),
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerRight, child: Text('Forgot password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary))),
              const SizedBox(height: 24),
              AppButton(label: 'Log In', onTap: () => _submit(context, () => Api.login(_email.text.trim(), _password.text))),
              const SizedBox(height: 20),
              Row(children: const [
                Expanded(child: Divider(color: AppColors.border)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(color: AppColors.muted))),
                Expanded(child: Divider(color: AppColors.border)),
              ]),
              const SizedBox(height: 20),
              AppButton(label: 'Continue with Google', style: BtnStyle.outline, icon: Icons.g_mobiledata, onTap: () => goToMain(context)),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () => _go(context, const SignUpScreen()),
                  child: const Text("Don't have an account?  Sign up", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────── Sign up ─────────
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _role = 'Trekker';
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget _roleBtn(String label, IconData icon) {
    final on = _role == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = label),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: on ? AppColors.tint : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: on ? AppColors.primary : AppColors.border, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: on ? AppColors.primary : AppColors.muted),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: on ? AppColors.primary : AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackCircle(bg: AppColors.bg, onTap: () => _go(context, const LoginScreen())),
              const SizedBox(height: 24),
              const Text('Create account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Join the community of Sri Lankan trekkers.', style: TextStyle(fontSize: 15, color: AppColors.muted)),
              const SizedBox(height: 24),
              AppField(label: 'Full name', hint: 'Your name', controller: _name),
              const SizedBox(height: 16),
              AppField(label: 'Email', hint: 'you@example.com', controller: _email),
              const SizedBox(height: 16),
              AppField(label: 'Password', hint: 'At least 8 characters', obscure: true, controller: _password),
              const SizedBox(height: 18),
              const Text('I am a', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(children: [_roleBtn('Trekker', Icons.hiking), const SizedBox(width: 12), _roleBtn('Shop Owner', Icons.storefront)]),
              const SizedBox(height: 24),
              AppButton(
                label: 'Create Account',
                onTap: () => _submit(context, () => Api.signup(_name.text.trim(), _email.text.trim(), _password.text, _role == 'Shop Owner' ? 'shop_owner' : 'trekker')),
              ),
              const SizedBox(height: 14),
              const Text('By signing up you agree to our Terms & Privacy Policy.', textAlign: TextAlign.center, style: AppText.small),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => _go(context, const LoginScreen()),
                  child: const Text('Already have an account?  Log in', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
