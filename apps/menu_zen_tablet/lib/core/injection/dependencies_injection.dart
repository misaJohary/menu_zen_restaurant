import 'package:data/di/data_package_module.module.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/injection/dependencies_injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
  externalPackageModulesBefore: [ExternalModule(DataPackageModule)],
)
Future<void> configureDependencies() async => getIt.init();
