import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _occupation = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName.text = prefs.getString('firstName') ?? '';
      _lastName.text = prefs.getString('lastName') ?? '';
      _age.text = prefs.getString('age') ?? '';
      _email.text = prefs.getString('email') ?? '';
      _address.text = prefs.getString('address') ?? '';
      _phone.text = prefs.getString('phone') ?? '';
      _occupation.text = prefs.getString('occupation') ?? '';
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('firstName', _firstName.text);
      await prefs.setString('lastName', _lastName.text);
      await prefs.setString('age', _age.text);
      await prefs.setString('email', _email.text);
      await prefs.setString('address', _address.text);
      await prefs.setString('phone', _phone.text);
      await prefs.setString('occupation', _occupation.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details updated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_firstName, "First Name"),
              _buildTextField(_lastName, "Last Name"),
              _buildTextField(_age, "Age", isNumber: true),
              _buildTextField(_email, "Email"),
              _buildTextField(_address, "Physical Address"),
              _buildTextField(_phone, "Phone"),
              _buildTextField(_occupation, "Occupation"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 45)),
                child: const Text("SAVE CHANGES"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
      ),
    );
  }
}
