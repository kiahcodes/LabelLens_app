import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wqdrvcoofglaofvkcccj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndxZHJ2Y29vZmdsYW9mdmtjY2NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyOTc1ODEsImV4cCI6MjA5MDg3MzU4MX0.KeYmrfrRSCJmBbeKU8kpDgBVJMzNYrBnwSCaFJB79Xc',
  );

  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'LabelLens + Supabase works!',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    ),
  );
}
