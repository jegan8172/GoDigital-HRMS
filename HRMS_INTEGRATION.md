# HRMS UI integration

This copy preserves the original Go Digital live application and its
authentication, providers, services, API code, and existing screens.

## Active UI mapping

- Authenticated admin users open the new HRMS admin portal.
- Authenticated employee users open the new HRMS employee portal.
- Designer, page-handler, ads-handler, and videographer entry routes use the
  new employee portal.
- Existing management routes and source screens remain available in the
  project and were not deleted.

## Added modules

- `Frontend/lib/hrms_admin/`
- `Frontend/lib/hrms_employee/`
- `Frontend/hrms_packages/hrms_design_system/`
- `Frontend/hrms_packages/hrms_responsive/`

## Safety copies

- `Frontend/lib/main.dart.pre-hrms.bak`
- `Frontend/pubspec.yaml.pre-hrms.bak`

## Verification

- Dependencies resolved successfully.
- Dart analysis found no compile-time errors. The original live source still
  reports its existing warnings and lint notices.
- Flutter release web build completed successfully.

Run `flutter pub get`, then use `flutter run -d chrome` from `Frontend`.
