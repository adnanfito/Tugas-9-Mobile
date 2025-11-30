# 🏪 Toko Kita - Aplikasi Mobile E-Commerce

Aplikasi Flutter modern untuk manajemen toko online dengan fitur lengkap Login, Registrasi, dan CRUD data produk. Dibangun dengan arsitektur BLoC dan integrasi API REST menggunakan Node.js backend.

---

## 📱 Fitur Utama

✅ **Autentikasi Pengguna** - Login & Registrasi dengan validasi  
✅ **Manajemen Produk** - Tambah, Edit, Hapus, dan Lihat detail produk  
✅ **Penyimpanan Token** - Autentikasi token berbasis JWT  
✅ **UI Modern** - Desain user-friendly dengan Material Design  
✅ **Error Handling** - Dialog notifikasi untuk success dan error  
✅ **BLoC Architecture** - State management terstruktur dan scalable

---

## 🛠️ Tech Stack

**Frontend:**

- Flutter 3.8.1+
- Dart
- HTTP Client (http: ^0.13.4)
- Shared Preferences (shared_preferences: ^2.0.11)

**Backend:**

- Node.js (NestJS)
- Prisma ORM
- SQLite Database

**Desain Pattern:**

- BLoC (Business Logic Component)
- MVC Architecture

---

## 🚀 Setup & Installation

### Prerequisites

- Flutter SDK 3.8.1 atau lebih baru
- Dart 3.0+
- Backend API running di `http://localhost:3000`

### Langkah Instalasi

```bash
# 1. Clone repository
git clone https://github.com/adnanfito/Tugas-9-Mobile.git
cd tokokita

# 2. Install dependencies
flutter pub get

# 3. Run aplikasi
flutter run
```

### Konfigurasi Backend

Pastikan backend sudah berjalan:

```bash
cd ../backend-mobile
npm install
npm run start:dev
```

---

## 🔐 PROSES LOGIN - STEP BY STEP

### **Step 1️⃣ : Halaman Login Kosong**

Pengguna pertama kali melihat halaman login dengan form input email dan password.

**File:** `lib/ui/login_page.dart`

```dart
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _emailTextboxController = TextEditingController();
  final _passwordTextboxController = TextEditingController();

  Widget _emailTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Email"),
      keyboardType: TextInputType.emailAddress,
      controller: _emailTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email harus diisi';
        }
        return null;
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Password"),
      keyboardType: TextInputType.text,
      obscureText: true,
      controller: _passwordTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password harus diisi";
        }
        return null;
      },
    );
  }
}
```

**Penjelasan:**

- Form dibuat dengan `GlobalKey<FormState>()` untuk validasi
- Email field memiliki validasi untuk memastikan field tidak kosong
- Password field menggunakan `obscureText: true` untuk menyembunyikan karakter

---

### **Step 2️⃣ : Input Kredensial**

Pengguna mengisikan email dan password mereka.



**Validasi Input:**

- ✅ Email tidak boleh kosong
- ✅ Password tidak boleh kosong
- ✅ Minimal 1 karakter untuk keduanya

---<img width="623" height="881" alt="Screenshot 2025-11-30 201147" src="https://github.com/user-attachments/assets/cf2d6866-0eab-4bc5-9ab9-622b9c03f7f1" />


### **Step 3️⃣ : Klik Tombol Login**

```dart
Widget _buttonLogin() {
  return ElevatedButton(
    onPressed: _isLoading
        ? null  // Tombol disabled saat loading
        : () {
            var validate = _formKey.currentState!.validate();
            if (validate) {
              _submit();  // Proses login
            }
          },
    child: const Text("Login"),
  );
}
```

Ketika tombol diklik, form akan divalidasi terlebih dahulu sebelum mengirim request.

---



### **Step 4️⃣ : Kirim Request ke Backend**

**File:** `lib/bloc/login_bloc.dart`
<img width="627" height="867" alt="Screenshot 2025-11-30 201156" src="https://github.com/user-attachments/assets/8195fa66-7941-4d00-8bed-58e667cedf82" />

```dart
class LoginBloc {
  static Future<Login> login({
    String? email,
    String? password
  }) async {
    try {
      String apiUrl = ApiUrl.login;  // http://localhost:3000/member/login
      var body = {
        "email": email,
        "password": password
      };

      // Kirim POST request ke backend
      var response = await Api().post(apiUrl, body);

      print('Login Status: ${response.statusCode}');
      print('Login Response: ${response.body}');

      // Validasi status code
      if (response.statusCode != 200) {
        throw Exception('Login failed with status ${response.statusCode}');
      }

      // Parse response JSON
      var jsonObj = json.decode(response.body);
      return Login.fromJson(jsonObj);

    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
```

**API Endpoint:**

```
POST /member/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response Success (200):**

```json
{
  "code": 200,
  "status": true,
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "nama": "John Doe"
    }
  }
}
```

---

### **Step 5️⃣ : Parse Response & Simpan Token**

**File:** `lib/model/login.dart`

```dart
class Login {
  int? code;
  bool? status;
  String? message;
  String? token;
  String? userID;

  Login({
    this.code,
    this.status,
    this.message,
    this.token,
    this.userID
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    print('🟠 [Login Model] Parsing: $json');

    // Extract token dari nested path data.token
    String? token = json['data']?['token'] as String?;
    String? userID = json['data']?['user']?['id']?.toString();

    return Login(
      code: json['code'] as int? ?? 200,
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      token: token ?? '',
      userID: userID ?? '',
    );
  }
}
```

Data token disimpan ke **Shared Preferences** untuk session management.

**File:** `lib/helpers/user_info.dart`

```dart
Future<void> setToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<void> setUserID(int userID) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userID', userID);
}
```

---

### **Step 6️⃣ : Tampilkan Dialog Success**

```dart
void _submit() {
  _formKey.currentState!.save();
  setState(() {
    _isLoading = true;
  });

  print('🔵 [LoginPage] Starting login..');

  LoginBloc.login(
    email: _emailTextboxController.text,
    password: _passwordTextboxController.text,
  ).then(
    (value) async {
      print('🟢 [LoginPage] Login response: code=${value.code}, token=${value.token}');

      // ✅ Validasi code 200 dan token tidak kosong
      if (value.code == 200 && value.token != null && value.token!.isNotEmpty) {
        try {
          // Simpan token
          await UserInfo().setToken(value.token!);
          await UserInfo().setUserID(int.parse(value.userID ?? '0'));

          // Tunggu sebentar untuk memastikan data tersimpan
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            // Tampilkan dialog success
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => SuccessDialog(
                description: "Login Berhasil",
                okClick: () {
                  print('🟣 [LoginPage] Navigating to ProdukPage..');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProdukPage(),
                    ),
                  );
                },
              ),
            );
          }
        } catch (e) {
          print('❌ [LoginPage] Error saving user data: $e');
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => const WarningDialog(
                description: "Gagal menyimpan data, silahkan coba lagi",
              ),
            );
          }
        }
      } else {
        // Login gagal
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => WarningDialog(
              description: value.message ?? "Login gagal",
            ),
          );
        }
      }
    },
    onError: (error) {
      print('❌ [LoginPage] Error: $error');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => WarningDialog(
            description: "Login gagal, silahkan coba lagi",
          ),
        );
      }
    },
  );
}
```

**File:** `lib/widget/success_dialog.dart`

```dart
class SuccessDialog extends StatelessWidget {
  final String? description;
  final VoidCallback? okClick;

  const SuccessDialog({
    Key? key,
    this.description,
    this.okClick
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              description ?? "Sukses",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: okClick,
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### **Step 7️⃣ : Navigasi ke Halaman Produk**

<img width="624" height="878" alt="Screenshot 2025-11-30 201223" src="https://github.com/user-attachments/assets/1b827d0f-edd2-4f08-b2d2-296b3e330181" />

Setelah login berhasil, aplikasi secara otomatis navigasi ke halaman daftar produk.

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const ProdukPage(),
  ),
);
```

**Menggunakan `pushReplacement`** agar pengguna tidak bisa kembali ke halaman login dengan back button.

---

### **Diagram Alur Login**

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Halaman Login Kosong                                         │
│    • Form Email & Password                                      │
│    • Tombol Login                                               │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. User Input Email & Password                                  │
│    • Email: user@example.com                                    │
│    • Password: password123                                      │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. Validasi Form                                                │
│    ✅ Email tidak kosong                                         │
│    ✅ Password tidak kosong                                      │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. Kirim POST Request ke API                                    │
│    POST /member/login                                           │
│    Body: {email, password}                                      │
└────────────────┬────────────────────────────────────────────────┘
                 │
          ┌──────────┴──────────┐
          │                     │
          ▼ (Status 200)        ▼ (Status != 200)
    ┌──────────────┐      ┌──────────────────┐
    │ Parse Token  │      │ Tampilkan Error  │
    └──────┬───────┘      │ Dialog           │
           │              └──────────────────┘
           ▼
    ┌──────────────────────┐
    │ Simpan Token ke      │
    │ Shared Preferences   │
    └──────┬───────────────┘
           │
           ▼
    ┌──────────────────────┐
    │ Tampilkan Success    │
    │ Dialog               │
    └──────┬───────────────┘
           │
           ▼
    ┌──────────────────────┐
    │ Navigasi ke Produk   │
    │ Page                 │
    └──────────────────────┘
```

---

## 📝 PROSES REGISTRASI - STEP BY STEP

### **Step 1️⃣ : Halaman Registrasi**

**File:** `lib/ui/registrasi_page.dart`

```dart
class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({Key? key}) : super(key: key);

  @override
  _RegistrasiPageState createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _namaTextboxController = TextEditingController();
  final _emailTextboxController = TextEditingController();
  final _passwordTextboxController = TextEditingController();
  final _passwordKonfirmasiTextboxController = TextEditingController();
}
```

Halaman registrasi memiliki 4 field input:

1. **Nama** - Minimal 3 karakter
2. **Email** - Format email valid
3. **Password** - Minimal 6 karakter
4. **Konfirmasi Password** - Harus sama dengan password

---

### **Step 2️⃣ : Validasi Input Registrasi**

```dart
Widget _namaTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Nama"),
    controller: _namaTextboxController,
    validator: (value) {
      if (value!.length < 3) {
        return "Nama harus diisi minimal 3 karakter";
      }
      return null;
    },
  );
}

Widget _emailTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Email"),
    keyboardType: TextInputType.emailAddress,
    controller: _emailTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return 'Email harus diisi';
      }
      // Validasi format email dengan regex
      Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = RegExp(pattern.toString());
      if (!regex.hasMatch(value)) {
        return "Email tidak valid";
      }
      return null;
    },
  );
}

Widget _passwordTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Password"),
    obscureText: true,
    controller: _passwordTextboxController,
    validator: (value) {
      if (value!.length < 6) {
        return "Password harus diisi minimal 6 karakter";
      }
      return null;
    },
  );
}

Widget _passwordKonfirmasiTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Konfirmasi Password"),
    obscureText: true,
    controller: _passwordKonfirmasiTextboxController,
    validator: (value) {
      if (value != _passwordTextboxController.text) {
        return "Konfirmasi Password tidak sama";
      }
      return null;
    },
  );
}
```

---

### **Step 3️⃣ : Kirim Request Registrasi**

**File:** `lib/bloc/registrasi_bloc.dart`

```dart
class RegistrasiBloc {
  static Future<Registrasi> registrasi({
    String? nama,
    String? email,
    String? password,
  }) async {
    String apiUrl = ApiUrl.registrasi;  // http://localhost:3000/member/registrasi
    var body = {
      "nama": nama,
      "email": email,
      "password": password
    };

    var response = await Api().post(apiUrl, body);
    var jsonObj = json.decode(response.body);
    return Registrasi.fromJson(jsonObj);
  }
}
```

**API Endpoint:**

```
POST /member/registrasi
Content-Type: application/json

{
  "nama": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

---

### **Step 4️⃣ : Tampilkan Dialog Success**

```dart
void _submit() {
  _formKey.currentState!.save();
  setState(() {
    _isLoading = true;
  });

  RegistrasiBloc.registrasi(
    nama: _namaTextboxController.text,
    email: _emailTextboxController.text,
    password: _passwordTextboxController.text,
  ).then(
    (value) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SuccessDialog(
          description: "Registrasi berhasil, silahkan login",
          okClick: () {
            Navigator.pop(context);  // Kembali ke halaman login
          },
        ),
      );
    },
    onError: (error) {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WarningDialog(
          description: "Registrasi gagal: $error",
        ),
      );
    },
  );
}
```

---

## 🛍️ PROSES CRUD PRODUK

### **A. READ (Tampilkan Daftar Produk)**

<img width="624" height="878" alt="Screenshot 2025-11-30 201223" src="https://github.com/user-attachments/assets/3d1671ad-8a56-402e-9f7f-bcc764f46bea" />

#### **Step 1️⃣ : Halaman Daftar Produk**

**File:** `lib/ui/produk_page.dart`

```dart
class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Produk'),
        actions: [
          // Tombol tambah produk (icon +)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: const Icon(Icons.add, size: 26.0),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProdukForm()),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout),
              onTap: () async {
                await LogoutBloc.logout().then(
                  (value) => {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    ),
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List>(
        future: ProdukBloc.getProduks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? ListProduk(list: snapshot.data)
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

#### **Step 2️⃣ : Fetch Data Produk dari API**

**File:** `lib/bloc/produk_bloc.dart`

```dart
class ProdukBloc {
  static Future<List<Produk>> getProduks() async {
    try {
      String apiUrl = ApiUrl.listProduk;  // http://localhost:3000/produk
      var response = await Api().get(apiUrl);

      print('🔵 Get Produks Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to load products');
      }

      var jsonObj = json.decode(response.body);

      if (jsonObj == null || jsonObj is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      List<dynamic> listProduk = jsonObj['data'] ?? [];
      List<Produk> produks = [];

      // Convert JSON ke list of Produk objects
      for (var item in listProduk) {
        produks.add(Produk.fromJson(item as Map<String, dynamic>));
      }

      return produks;
    } catch (e) {
      print('🔴 Error getProduks: $e');
      rethrow;
    }
  }
}
```

**Response Success:**

```json
{
  "code": 200,
  "status": true,
  "data": [
    {
      "id": 1,
      "kode_produk": "P001",
      "nama_produk": "Laptop",
      "harga": 8000000
    },
    {
      "id": 2,
      "kode_produk": "P002",
      "nama_produk": "Mouse",
      "harga": 150000
    }
  ]
}
```

#### **Step 3️⃣ : Display Produk di ListView**

```dart
class ListProduk extends StatelessWidget {
  final List? list;

  const ListProduk({Key? key, this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list == null ? 0 : list!.length,
      itemBuilder: (context, i) {
        return ItemProduk(produk: list![i]);
      },
    );
  }
}

class ItemProduk extends StatelessWidget {
  final Produk produk;

  const ItemProduk({Key? key, required this.produk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate ke detail produk saat di-tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProdukDetail(produk: produk),
          ),
        );
      },
      child: Card(
        child: ListTile(
          title: Text(produk.namaProduk!),
          subtitle: Text("Rp. " + produk.hargaProduk.toString()),
        ),
      ),
    );
  }
}
```

---

### **B. CREATE (Tambah Produk Baru)**



#### **Step 1️⃣ : Halaman Form Tambah Produk**

**File:** `lib/ui/produk_form.dart`<img width="633" height="875" alt="Screenshot 2025-11-30 201249" src="https://github.com/user-attachments/assets/6f15eccd-394b-4492-a020-50182b2a03e0" />

```dart
class ProdukForm extends StatefulWidget {
  final Produk? produk;  // null jika tambah, berisi data jika edit

  const ProdukForm({Key? key, this.produk}) : super(key: key);

  @override
  _ProdukFormState createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late String judul;
  late String tombolSubmit;
  final _kodeProdukTextboxController = TextEditingController();
  final _namaProdukTextboxController = TextEditingController();
  final _hargaProdukTextboxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.produk != null) {
      // Mode EDIT
      judul = "UBAH PRODUK";
      tombolSubmit = "UBAH";
      _kodeProdukTextboxController.text = widget.produk!.kodeProduk ?? '';
      _namaProdukTextboxController.text = widget.produk!.namaProduk ?? '';
      _hargaProdukTextboxController.text = widget.produk!.hargaProduk?.toString() ?? '';
    } else {
      // Mode TAMBAH
      judul = "TAMBAH PRODUK";
      tombolSubmit = "SIMPAN";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(judul)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _kodeProdukTextField(),
                _namaProdukTextField(),
                _hargaProdukTextField(),
                const SizedBox(height: 20),
                _buttonSubmit(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kodeProdukTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Kode Produk"),
      keyboardType: TextInputType.text,
      controller: _kodeProdukTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Kode Produk harus diisi";
        }
        return null;
      },
    );
  }

  Widget _namaProdukTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Nama Produk"),
      keyboardType: TextInputType.text,
      controller: _namaProdukTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Nama Produk harus diisi";
        }
        return null;
      },
    );
  }

  Widget _hargaProdukTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Harga"),
      keyboardType: TextInputType.number,
      controller: _hargaProdukTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Harga harus diisi";
        }
        if (int.tryParse(value) == null) {
          return "Harga harus berupa angka";
        }
        return null;
      },
    );
  }
}
```

#### **Step 2️⃣ : Validasi & Submit Form**

```dart
Widget _buttonSubmit() {
  return ElevatedButton(
    onPressed: _isLoading ? null : _handleSubmit,
    child: Text(tombolSubmit),
  );
}

void _handleSubmit() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (widget.produk != null) {
    _ubah();  // Update produk
  } else {
    _simpan();  // Tambah produk baru
  }
}
```

#### **Step 3️⃣ : Kirim Data ke API**

```dart
void _simpan() {
  setState(() {
    _isLoading = true;
  });

  Produk createProduk = Produk(
    kodeProduk: _kodeProdukTextboxController.text.trim(),
    namaProduk: _namaProdukTextboxController.text.trim(),
    hargaProduk: int.parse(_hargaProdukTextboxController.text.trim()),
  );

  print('🔵 [Simpan] Creating produk: $createProduk');

  ProdukBloc.addProduk(produk: createProduk).then(
    (value) {
      print('🟢 [Simpan] Success: $value');

      if (value) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const ProdukPage(),
            ),
          );
        }
      }
    },
    onError: (error) {
      print('🔴 [Simpan] Error: $error');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              WarningDialog(description: "Error: $error"),
        );
      }
    },
  );
}
```

**File:** `lib/bloc/produk_bloc.dart` - Method `addProduk`

```dart
static Future<bool> addProduk({required Produk produk}) async {
  try {
    String apiUrl = ApiUrl.createProduk;  // http://localhost:3000/produk

    var body = {
      "kode_produk": produk.kodeProduk ?? "",
      "nama_produk": produk.namaProduk ?? "",
      "harga": (produk.hargaProduk ?? 0).toString(),
    };

    print('🔵 [addProduk] URL: $apiUrl');
    print('🔵 [addProduk] Body: $body');

    var response = await Api().post(apiUrl, body);

    print('🟢 [addProduk] Status: ${response.statusCode}');
    print('🟢 [addProduk] Response: ${response.body}');

    // Accept status 200 dan 201
    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonObj = json.decode(response.body);
      print('🟡 [addProduk] Response parsed: $jsonObj');
      return true;
    } else {
      print('🔴 [addProduk] Error Status: ${response.statusCode}');
      throw Exception('Add produk failed with status ${response.statusCode}');
    }
  } catch (e) {
    print('🔴 [addProduk] Error: $e');
    rethrow;
  }
}
```

**Request API:**

```
POST /produk
Content-Type: application/json
Authorization: Bearer <token>

{
  "kode_produk": "P003",
  "nama_produk": "Keyboard",
  "harga": "500000"
}
```

<img width="630" height="877" alt="Screenshot 2025-11-30 201255" src="https://github.com/user-attachments/assets/713c4654-fcd2-446d-972c-52bfeaeb5fd8" />

---

### **C. UPDATE (Edit Produk)**

<img width="621" height="888" alt="Screenshot 2025-11-30 201306" src="https://github.com/user-attachments/assets/67125e37-6b5d-425a-9923-e1479d6a944a" />

#### **Step 1️⃣ : Akses Detail Produk**

**File:** `lib/ui/produk_detail.dart`

```dart
class ProdukDetail extends StatefulWidget {
  Produk? produk;

  ProdukDetail({Key? key, this.produk}) : super(key: key);

  @override
  _ProdukDetailState createState() => _ProdukDetailState();
}

class _ProdukDetailState extends State<ProdukDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Center(
        child: Column(
          children: [
            Text(
              "Kode : ${widget.produk!.kodeProduk}",
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              "Nama : ${widget.produk!.namaProduk}",
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              "Harga : Rp. ${widget.produk!.hargaProduk.toString()}",
              style: const TextStyle(fontSize: 18.0),
            ),
            _tombolHapusEdit(),
          ],
        ),
      ),
    );
  }

  Widget _tombolHapusEdit() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tombol Edit
        OutlinedButton(
          child: const Text("EDIT"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProdukForm(produk: widget.produk!),
              ),
            );
          },
        ),
        // Tombol Hapus
        OutlinedButton(
          child: const Text("DELETE"),
          onPressed: () => confirmHapus(),
        ),
      ],
    );
  }
}
```

#### **Step 2️⃣ : Form Edit dengan Pre-filled Data**

<img width="627" height="885" alt="Screenshot 2025-11-30 201317" src="https://github.com/user-attachments/assets/da7bed3e-128a-40ce-8f44-dc680cf3e60d" />

Saat user klik tombol EDIT, form akan ter-isi otomatis dengan data produk lama.

```dart
void _initializeForm() {
  if (widget.produk != null) {
    // Mode EDIT - isi form dengan data existing
    judul = "UBAH PRODUK";
    tombolSubmit = "UBAH";
    _kodeProdukTextboxController.text = widget.produk!.kodeProduk ?? '';
    _namaProdukTextboxController.text = widget.produk!.namaProduk ?? '';
    _hargaProdukTextboxController.text = widget.produk!.hargaProduk?.toString() ?? '';
  } else {
    // Mode TAMBAH - form kosong
    judul = "TAMBAH PRODUK";
    tombolSubmit = "SIMPAN";
  }
}
```

#### **Step 3️⃣ : Kirim Update Request**

```dart
void _ubah() {
  setState(() {
    _isLoading = true;
  });

  Produk updateProduk = Produk(
    id: widget.produk!.id,  // ⭐ Penting: include ID untuk update
    kodeProduk: _kodeProdukTextboxController.text,
    namaProduk: _namaProdukTextboxController.text,
    hargaProduk: int.parse(_hargaProdukTextboxController.text),
  );

  ProdukBloc.updateProduk(produk: updateProduk).then(
    (value) {
      if (value) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const ProdukPage(),
            ),
          );
        }
      }
    },
    onError: (error) {
      print('Error ubah: $error');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => const WarningDialog(
            description: "Permintaan ubah data gagal, silahkan coba lagi",
          ),
        );
      }
    },
  );
}
```

**File:** `lib/bloc/produk_bloc.dart` - Method `updateProduk`

```dart
static Future<bool> updateProduk({required Produk produk}) async {
  try {
    String apiUrl = ApiUrl.updateProduk(produk.id!);  // /produk/{id}/update
    print('🔵 [updateProduk] URL: $apiUrl');

    var body = {
      "kode_produk": produk.kodeProduk,
      "nama_produk": produk.namaProduk,
      "harga": produk.hargaProduk.toString(),
    };

    print("🔵 [updateProduk] Body: $body");

    var response = await Api().put(apiUrl, jsonEncode(body));

    print('🟢 [updateProduk] Status: ${response.statusCode}');
    print('🟢 [updateProduk] Response: ${response.body}');

    // Accept status 200 dan 201
    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonObj = json.decode(response.body);
      return true;
    } else {
      throw Exception('Update produk failed');
    }
  } catch (e) {
    print('🔴 [updateProduk] Error: $e');
    rethrow;
  }
}
```

**Request API:**

```
PUT /produk/1/update
Content-Type: application/json
Authorization: Bearer <token>

{
  "kode_produk": "P003",
  "nama_produk": "Keyboard Gaming",
  "harga": "550000"
}
```

<img width="623" height="888" alt="Screenshot 2025-11-30 201323" src="https://github.com/user-attachments/assets/9bab0052-4201-4767-b2cc-df11c149e8fc" />

---

### **D. DELETE (Hapus Produk)**

<img width="625" height="882" alt="Screenshot 2025-11-30 201332" src="https://github.com/user-attachments/assets/596af59d-2f04-4e13-8465-a714ca84a1a3" />

#### **Step 1️⃣ : Confirmation Dialog**

**File:** `lib/ui/produk_detail.dart`

```dart
void confirmHapus() {
  AlertDialog alertDialog = AlertDialog(
    content: const Text("Yakin ingin menghapus data ini?"),
    actions: [
      // Tombol Ya - Hapus
      OutlinedButton(
        child: const Text("Ya"),
        onPressed: () {
          ProdukBloc.deleteProduk(id: (widget.produk!.id!)).then(
            (value) => {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProdukPage()),
              ),
            },
            onError: (error) {
              showDialog(
                context: context,
                builder: (BuildContext context) => const WarningDialog(
                  description: "Hapus gagal, silahkan coba lagi",
                ),
              );
            },
          );
        },
      ),
      // Tombol Batal
      OutlinedButton(
        child: const Text("Batal"),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) => alertDialog,
  );
}
```

#### **Step 2️⃣ : Kirim Delete Request**

**File:** `lib/bloc/produk_bloc.dart` - Method `deleteProduk`

```dart
static Future<bool> deleteProduk({required int id}) async {
  try {
    String apiUrl = ApiUrl.deleteProduk(id);  // /produk/{id}
    print('🔵 [deleteProduk] URL: $apiUrl');

    var response = await Api().delete(apiUrl);

    print('🟢 [deleteProduk] Status: ${response.statusCode}');
    print('🟢 [deleteProduk] Response: ${response.body}');

    // Accept status 200, 201, dan 204 (No Content)
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Delete produk failed');
    }
  } catch (e) {
    print('🔴 [deleteProduk] Error: $e');
    rethrow;
  }
}
```

**Request API:**

```
DELETE /produk/1
Authorization: Bearer <token>
```

<img width="623" height="885" alt="Screenshot 2025-11-30 201338" src="https://github.com/user-attachments/assets/56dc97af-a122-4719-89dc-658d2fad7b3e" />

---

### **E. LOGOUT**

**File:** `lib/bloc/logout_bloc.dart`


```dart
class LogoutBloc {
  static Future<bool> logout() async {
    try {
      // Hapus token dari Shared Preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userID');

      print('🟢 Logout berhasil');
      return true;
    } catch (e) {
      print('🔴 Error logout: $e');
      rethrow;
    }
  }
}
```

**Navigation untuk Logout:**

```dart
await LogoutBloc.logout().then(
  (value) => {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,  // Remove all routes sebelumnya
    ),
  },
);
```

---

## 🔗 Flow Diagram CRUD Produk

```
                           ┌─────────────────┐
                           │  Produk Page    │
                           │  (List View)    │
                           └────────┬────────┘
                                    │
                  ┌─────────────────┼─────────────────┐
                  │                 │                 │
                  ▼                 ▼                 ▼
           ┌────────────┐    ┌────────────┐   ┌────────────┐
           │   READ     │    │   CREATE   │   │   Logout   │
           │  (Fetch)   │    │  (Tambah)  │   │            │
           └─────┬──────┘    └─────┬──────┘   └─────┬──────┘
                 │                 │                │
                 │                 ▼                │
                 │          ┌────────────────┐     │
                 │          │  ProdukForm    │     │
                 │          │  (Empty Form)  │     │
                 │          └─────┬──────────┘     │
                 │                │                │
                 │    ┌───────────┴───────────┐    │
                 │    │                       │    │
                 │    ▼                       ▼    │
                 │  ┌────────────┐       ┌────────────────┐
                 │  │ CREATE API │       │  UPDATE API    │
                 │  │   (POST)   │       │   (PUT)        │
                 │  └─────┬──────┘       └────────┬───────┘
                 │        │                       │
                 │        │                 ┌─────┴─────────┐
                 │        │                 │               │
                 ▼        ▼                 ▼               ▼
           ┌──────────────────┐      ┌────────────────┐    │
           │   Item Clicked   │      │  ProdukForm    │    │
           └────────┬─────────┘      │  (Pre-filled)  │    │
                    │                └────────┬───────┘    │
                    ▼                         │            │
           ┌──────────────────┐              │            │
           │ ProdukDetail     │              │            │
           │ (Show Details)   │              │            │
           └────────┬─────────┘              │            │
                    │                        │            │
          ┌─────────┴─────────┐              │            │
          │                   │              │            │
          ▼                   ▼              ▼            ▼
      ┌────────┐          ┌────────────┐ ┌────────────────┐
      │ EDIT   │          │   DELETE   │ │   Success      │
      │ Button │          │  Button    │ │   Dialog       │
      └───┬────┘          └────┬───────┘ └────────┬───────┘
          │                    │                  │
          └────────┬───────────┘                  │
                   │                              │
                   ▼                              │
        ┌──────────────────────┐                 │
        │ Confirm Dialog       │                 │
        │ (Edit/Delete?)       │                 │
        └──────────┬───────────┘                 │
                   │                             │
        ┌──────────┴──────────┐                  │
        │                     │                  │
        ▼ (Edit)              ▼ (Delete)         │
    ┌────────┐            ┌──────────┐          │
    │ UPDATE │            │  DELETE  │          │
    │  API   │            │   API    │          │
    └───┬────┘            └────┬─────┘          │
        │                      │                │
        └──────────┬───────────┘                │
                   │                           │
                   └──────────────┬────────────┘
                                  │
                                  ▼
                        ┌──────────────────┐
                        │ Back to Produk   │
                        │ Page (Refresh)   │
                        └──────────────────┘
```

---

## 🏗️ Arsitektur Aplikasi

### **BLoC Pattern - Pemisahan Logic & UI**

```
┌─────────────────────────────────────────────┐
│         Presentation Layer (UI)             │
│  ├─ LoginPage                               │
│  ├─ RegistrasiPage                          │
│  ├─ ProdukPage                              │
│  ├─ ProdukForm                              │
│  ├─ ProdukDetail                            │
│  └─ Dialogs (Success & Warning)             │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│         Business Logic Layer (BLoC)         │
│  ├─ LoginBloc.login()                       │
│  ├─ RegistrasiBloc.registrasi()             │
│  ├─ ProdukBloc.getProduks()                 │
│  ├─ ProdukBloc.addProduk()                  │
│  ├─ ProdukBloc.updateProduk()               │
│  ├─ ProdukBloc.deleteProduk()               │
│  └─ LogoutBloc.logout()                     │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│         Data Layer (API & Storage)          │
│  ├─ Api (HTTP Client)                       │
│  ├─ ApiUrl (Endpoints)                      │
│  ├─ UserInfo (SharedPreferences)            │
│  └─ Models (Login, Registrasi, Produk)     │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│         Backend API (Node.js)               │
│  ├─ /member/login                           │
│  ├─ /member/registrasi                      │
│  ├─ /produk (GET, POST)                     │
│  ├─ /produk/:id (GET, PUT, DELETE)         │
│  └─ Database (SQLite)                       │
└─────────────────────────────────────────────┘
```

---

## 🔑 Key Features & Explanations

### **1. Token-Based Authentication**

Aplikasi menggunakan JWT token untuk autentikasi:

```dart
// Simpan token setelah login
await UserInfo().setToken(value.token!);

// Retrieve token saat fetch data
var token = await UserInfo().getToken();

// Gunakan token di header
Api().get(apiUrl, token);
```

### **2. Error Handling**

Semua API calls memiliki error handling:

```dart
.then(
  (value) {
    // Success handling
  },
  onError: (error) {
    // Error handling
    showDialog(
      context: context,
      builder: (context) => WarningDialog(description: "Error: $error"),
    );
  },
)
```

### **3. Form Validation**

Input form divalidasi sebelum submit:

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return "Field harus diisi";
  }
  return null;
}
```

### **4. Navigation**

- `push()` - Add route to stack (bisa back)
- `pushReplacement()` - Replace route (tidak bisa back)
- `pushAndRemoveUntil()` - Remove semua route sebelumnya

### **5. Loading State**

Button disabled saat loading:

```dart
onPressed: _isLoading ? null : _handleSubmit,
```

---

## 🧪 Testing Tips

### **Testing Login**

```
Email: user@example.com
Password: password123
```

### **Testing Registrasi**

```
Nama: John Doe
Email: newemail@example.com
Password: password123
Konfirmasi Password: password123
```

### **Testing CRUD**

- **Create**: Isi form dan klik Simpan
- **Read**: Lihat daftar di Produk Page
- **Update**: Klik item → Edit → Ubah data → Klik Ubah
- **Delete**: Klik item → Delete → Konfirmasi Hapus

---

## 🚨 Troubleshooting

### **Issue: Login Gagal**

- Pastikan backend API running di `http://localhost:3000`
- Check email & password di database
- Lihat console log untuk detail error

### **Issue: Produk Tidak Muncul**

- Refresh halaman
- Check token validity
- Lihat API response di console

### **Issue: Token Expired**

- Logout dan login kembali
- Token akan di-update otomatis

---

## 📚 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^0.13.4 # HTTP Client
  shared_preferences: ^2.0.11 # Local Storage
```

---

## 👨‍💻 Developer

**Adnan Fito**

- Repository: https://github.com/adnanfito/Tugas-9-Mobile
- Branch: master

---

## 📄 License

This project is open source and available under the MIT License.

---

## 📞 Support

Jika ada pertanyaan atau issue, silakan buat issue di repository GitHub.

---

**Last Updated:** November 30, 2025  
**Version:** 1.0.0  
**Status:** Production Ready ✅
