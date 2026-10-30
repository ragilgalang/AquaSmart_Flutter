import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'petambak@aquasmart.com');
  final _password = TextEditingController(text: 'password123');
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await context.read<AuthProvider>().login(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = (screenHeight * 0.32).clamp(240.0, 300.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Bergaya Gelombang Organik (Persis Mockup)
            Stack(
              children: [
                // Layer Garis Gelombang Aksen Mint di bawah
                ClipPath(
                  clipper: _WaveClipper(offsetY: 10),
                  child: Container(
                    height: headerHeight + 14,
                    color: const Color(0xFFBCE3D7),
                  ),
                ),

                // Layer Gelombang Utama Dark Teal
                ClipPath(
                  clipper: _WaveClipper(offsetY: 0),
                  child: Container(
                    height: headerHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B4D3C),
                    ),
                    child: Stack(
                      children: [
                        // Lingkaran dekoratif abstrak latar belakang
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.04),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: -40,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.03),
                            ),
                          ),
                        ),

                        // Konten Logo & Brand
                        SafeArea(
                          bottom: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Kotak Ikon Squircle Putih
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.water_drop_rounded,
                                        size: 38,
                                        color: Color(0xFF0B4D3C),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'AquaSmart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Form Login
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat datang kembali',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF132B23),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Masuk untuk memantau kondisi air Tambak Maneron.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A756B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Input Email
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF132B23),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF132B23),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'nama@domain.com',
                        hintStyle: const TextStyle(color: Color(0xFF9EABA4)),
                        prefixIcon: const Icon(
                          Icons.mail_outline_rounded,
                          color: Color(0xFF4A6B5D),
                          size: 22,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2EBE6), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2EBE6), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF0B4D3C), width: 1.5),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                    ),
                    const SizedBox(height: 18),

                    // Input Password
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF132B23),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _password,
                      obscureText: _hide,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF132B23),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '••••••••••••',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF4A6B5D),
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hide ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: const Color(0xFF4A6B5D),
                            size: 22,
                          ),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2EBE6), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2EBE6), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF0B4D3C), width: 1.5),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                    ),

                    if (auth.error != null) ...[
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          auth.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 26),

                    // Tombol Masuk ->
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: auth.loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B4D3C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 0,
                        ),
                        child: auth.loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Footer: Sensor tambak aktif dan terhubung
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Sensor tambak aktif dan terhubung',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5A756B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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

/// Custom Clipper untuk membuat lengkungan gelombang organik di header
class _WaveClipper extends CustomClipper<Path> {
  final double offsetY;
  _WaveClipper({this.offsetY = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 35 + offsetY);

    // Gelombang pertama (turun lalu naik)
    final firstControlPoint = Offset(size.width * 0.28, size.height + offsetY);
    final firstEndPoint = Offset(size.width * 0.55, size.height - 20 + offsetY);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Gelombang kedua (naik lembut ke kanan)
    final secondControlPoint = Offset(size.width * 0.82, size.height - 40 + offsetY);
    final secondEndPoint = Offset(size.width, size.height - 15 + offsetY);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
