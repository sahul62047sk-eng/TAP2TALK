
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

const bg = Color(0xFF090909);
const red = Color(0xFFFF202A);
const gold = Color(0xFFFFD21C);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Tap2TalkApp());
}

class Tap2TalkApp extends StatelessWidget {
  const Tap2TalkApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'TAP2TALK',
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: gold, secondary: red),
      appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: gold),
    ),
    home: const Gate(),
  );
}

class Gate extends StatefulWidget {
  const Gate({super.key});
  @override State<Gate> createState() => _GateState();
}
class _GateState extends State<Gate> {
  bool loading = true;
  @override void initState() { super.initState(); _init(); }
  Future<void> _init() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }
  @override Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: gold)));
    return const JoinPage();
  }
}

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});
  @override State<JoinPage> createState() => _JoinPageState();
}
class _JoinPageState extends State<JoinPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool sending = false;
  Future<void> submit() async {
    if (name.text.trim().isEmpty || phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name aur WhatsApp number bharein')));
      return;
    }
    setState(() => sending = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('memberRequests').doc(uid).set({
        'uid': uid, 'name': name.text.trim(), 'whatsapp': phone.text.trim(),
        'status': 'pending', 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approval request bhej di gayi. Admin approval ka wait karein.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request submit nahi hui: $e')));
    }
    if (mounted) setState(() => sending = false);
  }
  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
      children: [
        TweenAnimationBuilder<double>(tween: Tween(begin: .78, end: 1), duration: const Duration(milliseconds: 1000),
          curve: Curves.elasticOut, builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
          child: ClipOval(child: Image.asset('assets/tap2talk_logo.png', width: 190, height: 190, fit: BoxFit.cover))),
        const SizedBox(height: 16),
        const Text('TAP2TALK', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: gold, letterSpacing: 2)),
        const Text('Connect • Share • Enjoy', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 30),
        field(name, 'Your Name'),
        const SizedBox(height: 12),
        field(phone, 'WhatsApp Number (with country code)', type: TextInputType.phone),
        const SizedBox(height: 18),
        GlowButton(label: sending ? 'Sending...' : 'REQUEST APPROVAL', onTap: sending ? null : submit),
        const SizedBox(height: 16),
        const Text('Number ownership is not verified by OTP. Access requires admin approval.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    )))),
  );
}

Widget field(TextEditingController c, String hint, {TextInputType type = TextInputType.text}) => TextField(
  controller: c, keyboardType: type, style: const TextStyle(color: Colors.white),
  decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFF191919),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: red)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12))),
);

class GlowButton extends StatelessWidget {
  final String label; final VoidCallback? onTap;
  const GlowButton({super.key, required this.label, required this.onTap});
  @override Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300), width: double.infinity,
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [red, gold]),
      borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: red, blurRadius: 12, spreadRadius: 1)]),
    child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
  );
}

// Admin IDs must be added securely before enabling admin controls.
// This starter only creates pending member requests; secure rules are required for production.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('TAP2TALK')),
    body: ListView(padding: const EdgeInsets.all(16), children: const [
      SectionTile('🎁 Giveaway', 'Giveaway posts and winners'),
      SectionTile('📘 Method', 'Method details, video and redirect links'),
      SectionTile('🔐 Premium Method', 'Admin-set price and manual purchase approval'),
      SectionTile('💬 All Members Chat', 'Approved members only'),
      SectionTile('🛡 Admin Approval', 'Approve/reject requests; ban/unban members'),
    ]),
  );
}
class SectionTile extends StatelessWidget {
  final String title, subtitle;
  const SectionTile(this.title, this.subtitle, {super.key});
  @override Widget build(BuildContext context) => Card(color: const Color(0xFF171717), shape: RoundedRectangleBorder(
    side: const BorderSide(color: red), borderRadius: BorderRadius.circular(16)),
    child: ListTile(title: Text(title, style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle), trailing: const Icon(Icons.arrow_forward_ios, color: red, size: 16)));
}
