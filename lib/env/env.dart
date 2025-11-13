import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField()
  static const String GOOGLE_API_KEY = _Env.GOOGLE_API_KEY;
}
