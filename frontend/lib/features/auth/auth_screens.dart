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

// Mountain picture that fades into the dark page colour at the bottom.
class _DarkHero extends StatelessWidget {
  final Widget? child;
  const _DarkHero({this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const MountainScene(colors: [Color(0xFF7E9AA6), Color(0xFFD9D2B8)]),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x6613261C), Color(0x1113261C), AppColors.dark], stops: [0, .5, 1]),
          ),
        ),
        ?child,
      ],
    );
  }
}

// ───────── Splash ─────────
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const Positioned.fill(child: _DarkHero()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const BrandLogo(),
                  const Spacer(flex: 4),
                  const Text('Explore Sri Lanka.\nTrek Beyond the Ordinary.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.onDark, height: 1.5)),
                  const SizedBox(height: 28),
                  AppButton(label: 'Get Started', onTap: () => _go(context, const OnboardingScreen())),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _go(context, const LoginScreen()),
                    child: const Text('I already have an account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
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
  _ObData(Icons.landscape, 'Discover Breathtaking Treasures', 'Explore mountains, waterfalls, forests and hidden trails across Sri Lanka.', [Color(0xFF9DBFC9), Color(0xFFDDE6D8)]),
  _ObData(Icons.wifi_off, 'Navigate Even Without Signal', 'Download trek maps before you go. GPS keeps tracking you on the trail, no internet needed.', [Color(0xFFF1B27A), Color(0xFFF8DDB0)]),
  _ObData(Icons.local_parking, 'Park Smart, Gear Up Locally', 'Find trailhead parking and nearby gear rental shops so you arrive prepared.', [Color(0xFF6F93B5), Color(0xFFBFD3DE)]),
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
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => _go(context, const LoginScreen()), child: const Text('Skip', style: TextStyle(color: AppColors.muted, fontSize: 15))),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: _obPages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _ObPage(data: _obPages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 20),
              child: Row(
                children: [
                  ...List.generate(3, (i) {
                    final on = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 6),
                      width: on ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(color: on ? AppColors.primary : AppColors.border, borderRadius: BorderRadius.circular(4)),
                    );
                  }),
                  const Spacer(),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 26),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObPage extends StatelessWidget {
  final _ObData data;
  const _ObPage({required this.data});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(180), bottom: Radius.circular(28)),
              child: MountainScene(
                colors: data.colors,
                child: Align(
                  alignment: const Alignment(0, -0.35),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                    child: Icon(data.icon, size: 46, color: AppColors.dark),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(data.title, textAlign: TextAlign.center, style: AppText.display),
          const SizedBox(height: 14),
          Text(data.body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppColors.muted, height: 1.5)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ───────── Login / Sign up (shared dark layout with tabs) ─────────
class _AuthLayout extends StatelessWidget {
  final bool login;
  final List<Widget> children;
  const _AuthLayout({required this.login, required this.children});

  Widget _tab(BuildContext context, String label, bool on, Widget target) {
    return Expanded(
      child: GestureDetector(
        onTap: on ? null : () => _go(context, target),
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: on ? Colors.white : const Color(0x33FFFFFF), width: on ? 2 : 1))),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: on ? Colors.white : const Color(0xFF9FB3A6))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: h * .34,
              child: const _DarkHero(
                child: SafeArea(
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      BrandLogo(scale: .7),
                      SizedBox(height: 8),
                      Text('Your Trekking Companion', style: TextStyle(fontSize: 13, color: AppColors.onDark)),
                    ]),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [_tab(context, 'Login', login, const LoginScreen()), _tab(context, 'Sign Up', !login, const SignUpScreen())]),
                  const SizedBox(height: 24),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      login: true,
      children: [
        AppField(hint: 'Email', icon: Icons.person_outline, dark: true, controller: _email),
        const SizedBox(height: 14),
        AppField(hint: 'Password', icon: Icons.lock_outline, obscure: true, dark: true, controller: _password),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 24,
              child: Checkbox(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v ?? false),
                activeColor: AppColors.accent,
                side: const BorderSide(color: Color(0xFF9FB3A6)),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Remember me', style: TextStyle(fontSize: 13, color: AppColors.onDark)),
            const Spacer(),
            const Text('Forgot Password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.accent)),
          ],
        ),
        const SizedBox(height: 20),
        AppButton(label: 'Login', onTap: () => _submit(context, () => Api.login(_email.text.trim(), _password.text))),
        const SizedBox(height: 22),
        const Text('or continue with', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF9FB3A6))),
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: () => goToMain(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.darkCard,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(width: 10),
              Text('Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
            ]),
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: GestureDetector(
            onTap: () => _go(context, const SignUpScreen()),
            child: const Text.rich(TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(fontSize: 14, color: AppColors.onDark),
              children: [TextSpan(text: 'Sign Up', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.accent))],
            )),
          ),
        ),
      ],
    );
  }
}

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
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: on ? AppColors.accent : AppColors.darkCard, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: on ? AppColors.accent : const Color(0xFF9FB3A6)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: on ? Colors.white : const Color(0xFF9FB3A6))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      login: false,
      children: [
        AppField(hint: 'Full name', icon: Icons.badge_outlined, dark: true, controller: _name),
        const SizedBox(height: 14),
        AppField(hint: 'Email', icon: Icons.person_outline, dark: true, controller: _email),
        const SizedBox(height: 14),
        AppField(hint: 'Password (8+ characters)', icon: Icons.lock_outline, obscure: true, dark: true, controller: _password),
        const SizedBox(height: 18),
        const Text('I am a', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onDark)),
        const SizedBox(height: 8),
        Row(children: [_roleBtn('Trekker', Icons.hiking), const SizedBox(width: 12), _roleBtn('Shop Owner', Icons.storefront)]),
        const SizedBox(height: 24),
        AppButton(
          label: 'Create Account',
          onTap: () => _submit(context, () => Api.signup(_name.text.trim(), _email.text.trim(), _password.text, _role == 'Shop Owner' ? 'shop_owner' : 'trekker')),
        ),
        const SizedBox(height: 14),
        const Text('By signing up you agree to our Terms & Privacy Policy.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF9FB3A6))),
      ],
    );
  }
}
