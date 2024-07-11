import 'package:batch_flutter/batch.dart';
import 'package:flutter/material.dart';

class DataCollectionSetting {
  String name;
  bool enabled;

  DataCollectionSetting({required this.name, required this.enabled});
}

class SettingsCategory extends StatelessWidget {
  final String title;

  const SettingsCategory({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SwitchSetting extends StatefulWidget {
  final DataCollectionSetting setting;

  const SwitchSetting({Key? key, required this.setting}) : super(key: key);

  @override
  _SwitchSettingState createState() => _SwitchSettingState();
}

class _SwitchSettingState extends State<SwitchSetting> {late bool isEnabled;

@override
void initState() {
  super.initState();
  isEnabled = widget.setting.enabled;
}

void onChange() {
  setState(() {
    isEnabled = !isEnabled;
    widget.setting.enabled = isEnabled;
  });
}

@override
Widget build(BuildContext context) {
  return InkWell(
    onTap: onChange,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.setting.name),
        Switch(
          value: isEnabled,
          onChanged: (value) => onChange(),
        ),
      ],
    ),
  );
}
}

class DataCollectionSettings extends StatefulWidget {
  const DataCollectionSettings({Key? key}) : super(key: key);

  @override
  _DataCollectionSettingsState createState() => _DataCollectionSettingsState();
}

class _DataCollectionSettingsState extends State<DataCollectionSettings> {
  final deviceBrandSetting = DataCollectionSetting(
    name: 'Device Brand',
    enabled: false,
  );
  final deviceModelSetting = DataCollectionSetting(
    name: 'Device Model',
    enabled: false,
  );
  final geoIPSetting = DataCollectionSetting(
    name: 'GeoIP',
    enabled: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsCategory(title: 'Automatic Data Collection'),
            if (Theme.of(context).platform == TargetPlatform.android)
              SwitchSetting(setting: deviceBrandSetting),
            SwitchSetting(setting: deviceModelSetting),
            SwitchSetting(setting: geoIPSetting),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Batch.instance.setAutomaticDataCollection({
                    "deviceBrand": deviceBrandSetting.enabled,
                    "deviceModel": deviceModelSetting.enabled,
                    "geoIP": geoIPSetting.enabled,
                  });
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
