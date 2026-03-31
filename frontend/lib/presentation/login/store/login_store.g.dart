// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on _UserStore, Store {
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading => (_$isLoadingComputed ??= Computed<bool>(
    () => super.isLoading,
    name: '_UserStore.isLoading',
  )).value;

  late final _$isLoggedInAtom = Atom(
    name: '_UserStore.isLoggedIn',
    context: context,
  );

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$successAtom = Atom(name: '_UserStore.success', context: context);

  @override
  bool get success {
    _$successAtom.reportRead();
    return super.success;
  }

  @override
  set success(bool value) {
    _$successAtom.reportWrite(value, super.success, () {
      super.success = value;
    });
  }

  late final _$registerSuccessAtom = Atom(
    name: '_UserStore.registerSuccess',
    context: context,
  );

  @override
  bool get registerSuccess {
    _$registerSuccessAtom.reportRead();
    return super.registerSuccess;
  }

  @override
  set registerSuccess(bool value) {
    _$registerSuccessAtom.reportWrite(value, super.registerSuccess, () {
      super.registerSuccess = value;
    });
  }

  late final _$passwordResetSuccessAtom = Atom(
    name: '_UserStore.passwordResetSuccess',
    context: context,
  );

  @override
  bool get passwordResetSuccess {
    _$passwordResetSuccessAtom.reportRead();
    return super.passwordResetSuccess;
  }

  @override
  set passwordResetSuccess(bool value) {
    _$passwordResetSuccessAtom.reportWrite(
      value,
      super.passwordResetSuccess,
      () {
        super.passwordResetSuccess = value;
      },
    );
  }

  late final _$isRegisterLoadingAtom = Atom(
    name: '_UserStore.isRegisterLoading',
    context: context,
  );

  @override
  bool get isRegisterLoading {
    _$isRegisterLoadingAtom.reportRead();
    return super.isRegisterLoading;
  }

  @override
  set isRegisterLoading(bool value) {
    _$isRegisterLoadingAtom.reportWrite(value, super.isRegisterLoading, () {
      super.isRegisterLoading = value;
    });
  }

  late final _$isForgotPasswordLoadingAtom = Atom(
    name: '_UserStore.isForgotPasswordLoading',
    context: context,
  );

  @override
  bool get isForgotPasswordLoading {
    _$isForgotPasswordLoadingAtom.reportRead();
    return super.isForgotPasswordLoading;
  }

  @override
  set isForgotPasswordLoading(bool value) {
    _$isForgotPasswordLoadingAtom.reportWrite(
      value,
      super.isForgotPasswordLoading,
      () {
        super.isForgotPasswordLoading = value;
      },
    );
  }

  late final _$loginFutureAtom = Atom(
    name: '_UserStore.loginFuture',
    context: context,
  );

  @override
  ObservableFuture<User?> get loginFuture {
    _$loginFutureAtom.reportRead();
    return super.loginFuture;
  }

  @override
  set loginFuture(ObservableFuture<User?> value) {
    _$loginFutureAtom.reportWrite(value, super.loginFuture, () {
      super.loginFuture = value;
    });
  }

  late final _$loginAsyncAction = AsyncAction(
    '_UserStore.login',
    context: context,
  );

  @override
  Future<void> login(String email, String password) {
    return _$loginAsyncAction.run(() => super.login(email, password));
  }

  late final _$registerAsyncAction = AsyncAction(
    '_UserStore.register',
    context: context,
  );

  @override
  Future<void> register(String name, String email, String password) {
    return _$registerAsyncAction.run(
      () => super.register(name, email, password),
    );
  }

  late final _$forgotPasswordAsyncAction = AsyncAction(
    '_UserStore.forgotPassword',
    context: context,
  );

  @override
  Future<void> forgotPassword(String email) {
    return _$forgotPasswordAsyncAction.run(() => super.forgotPassword(email));
  }

  late final _$logoutAsyncAction = AsyncAction(
    '_UserStore.logout',
    context: context,
  );

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  late final _$_UserStoreActionController = ActionController(
    name: '_UserStore',
    context: context,
  );

  @override
  void clearSession() {
    final _$actionInfo = _$_UserStoreActionController.startAction(
      name: '_UserStore.clearSession',
    );
    try {
      return super.clearSession();
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoggedIn: ${isLoggedIn},
success: ${success},
registerSuccess: ${registerSuccess},
passwordResetSuccess: ${passwordResetSuccess},
isRegisterLoading: ${isRegisterLoading},
isForgotPasswordLoading: ${isForgotPasswordLoading},
loginFuture: ${loginFuture},
isLoading: ${isLoading}
    ''';
  }
}
