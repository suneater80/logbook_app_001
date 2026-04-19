class AccessControlService {
  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  static const Map<String, Set<String>> _rolePermissions = {
    'Ketua': {actionCreate, actionRead, actionUpdate, actionDelete},
    'Anggota': {actionCreate, actionRead},
  };

  static bool canPerform(String role, String action, {bool isOwner = false}) {
    if (action == actionUpdate || action == actionDelete) {
      return isOwner;
    }

    final permissions = _rolePermissions[role];
    if (permissions == null) {
      return false;
    }

    return permissions.contains(action);
  }
}
