import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://uzojuaerppcqtanvvzvd.supabase.co',   // your project URL
      anonKey: 'sb_publishable_k6NXOhYOjn6WpYEomwAigQ_xoUcVh4o',     // your publishable key
    );
  }
}