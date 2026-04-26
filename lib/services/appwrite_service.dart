import 'package:appwrite/appwrite.dart';

class AppwriteService {
  late Client client;
  late Account account;
  late TablesDB databases;
  late Storage storage;
  late Realtime realtime;
  AppwriteService() {
    _initAppwrite();
  }

  void _initAppwrite() {
    client = Client();
    client
        .setEndpoint(
            'https://fra.cloud.appwrite.io/v1') // Your Appwrite Endpoint
        .setProject(
            '697295e70021593c3438'); // For self-signed certificates, specify true for development

    account = Account(client);
    databases = TablesDB(client);
    storage = Storage(client);
    realtime = Realtime(client);
  }
}
