import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables untuk menyimpan setting sementara di UI
  late bool _isDarkMode;
  late bool _isNotificationEnabled;
  late String _calculationMethod;
  late String _madhab;
  late bool _useManualLocation;
  
  // Controller untuk lokasi manual
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _cityController = TextEditingController();

  // Menandai jika ada perubahan yang belum di-save
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Ambil data awal dari PreferencesService
    _isDarkMode = PreferencesService.isDarkMode;
    _isNotificationEnabled = PreferencesService.isNotificationEnabled;
    _calculationMethod = PreferencesService.calculationMethod;
    _madhab = PreferencesService.madhab;
    _useManualLocation = PreferencesService.useManualLocation;
    
    _latController.text = PreferencesService.manualLatitude.toString();
    _lngController.text = PreferencesService.manualLongitude.toString();
    _cityController.text = PreferencesService.manualCityName;
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    // Simpan semua state UI ke PreferencesService
    await PreferencesService.setDarkMode(_isDarkMode);
    await PreferencesService.setNotificationEnabled(_isNotificationEnabled);
    await PreferencesService.setCalculationMethod(_calculationMethod);
    await PreferencesService.setMadhab(_madhab);
    await PreferencesService.setUseManualLocation(_useManualLocation);
    
    if (_useManualLocation) {
      final lat = double.tryParse(_latController.text) ?? AppDefaults.defaultLatitude;
      final lng = double.tryParse(_lngController.text) ?? AppDefaults.defaultLongitude;
      await PreferencesService.setManualLatitude(lat);
      await PreferencesService.setManualLongitude(lng);
      
      final city = _cityController.text.trim();
      await PreferencesService.setManualCityName(
          city.isEmpty ? AppDefaults.defaultCityName : city);
    }

    if (mounted) {
      // Kembali ke layar sebelumnya dengan hasil "true" (artinya perlu refresh)
      Navigator.pop(context, true);
    }
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        actions: [
          // Tampilkan tombol centang hanya jika ada perubahan
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveSettings,
            )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- KELOMPOK: TAMPILAN ---
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('TAMPILAN', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal)),
          ),
          SwitchListTile(
            title: const Text('Mode Gelap'),
            value: _isDarkMode,
            activeColor: AppColors.primaryGreen,
            onChanged: (val) {
              setState(() => _isDarkMode = val);
              _markAsChanged();
            },
          ),
          
          const Divider(height: 32),

          // --- KELOMPOK: NOTIFIKASI ---
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('NOTIFIKASI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal)),
          ),
          SwitchListTile(
            title: const Text('Notifikasi Adzan'),
            subtitle: const Text('Tampilkan notifikasi saat waktu sholat tiba'),
            value: _isNotificationEnabled,
            activeColor: AppColors.primaryGreen,
            onChanged: (val) {
              setState(() => _isNotificationEnabled = val);
              _markAsChanged();
            },
          ),

          const Divider(height: 32),

          // --- KELOMPOK: PERHITUNGAN SHOLAT ---
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('PERHITUNGAN WAKTU', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Metode Perhitungan',
              border: OutlineInputBorder(),
            ),
            value: _calculationMethod,
            isExpanded: true,
            items: CalculationMethodHelper.labels.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _calculationMethod = val);
                _markAsChanged();
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Madzhab (Mempengaruhi Waktu Ashar)',
              border: OutlineInputBorder(),
            ),
            value: _madhab,
            items: MadhabHelper.labels.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _madhab = val);
                _markAsChanged();
              }
            },
          ),

          const Divider(height: 32),

          // --- KELOMPOK: LOKASI ---
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('LOKASI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal)),
          ),
          SwitchListTile(
            title: const Text('Gunakan Lokasi Manual'),
            subtitle: const Text('Matikan untuk menggunakan GPS otomatis'),
            value: _useManualLocation,
            activeColor: AppColors.primaryGreen,
            onChanged: (val) {
              setState(() => _useManualLocation = val);
              _markAsChanged();
            },
          ),
          
          if (_useManualLocation) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Nama Kota',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _markAsChanged(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    onChanged: (_) => _markAsChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    onChanged: (_) => _markAsChanged(),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Tombol Save
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChanges ? AppColors.primaryGreen : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _hasChanges ? _saveSettings : null,
            child: const Text('SIMPAN PENGATURAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
