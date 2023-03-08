import 'package:mac_address/mac_address.dart';
import 'package:new_package_demo/constants.dart';

class MacAddressService {
  static Future<String> getMacAddress() async {
    String macAddress = await GetMac.macAddress;
    print(macAddress);
    Constants.macAddress = macAddress;
    return macAddress;
  }
}
