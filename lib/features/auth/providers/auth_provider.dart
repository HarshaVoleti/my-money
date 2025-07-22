import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/user_model.dart';
import 'package:my_money/core/providers/service_providers.dart';

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {

  AuthNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }
  final Ref ref;
  StreamSubscription<User?>? _authSubscription;

  Future<void> _init() async {
    try {
      final authService = ref.read(authServiceProvider);

      // Listen to auth state changes
      _authSubscription = authService.authStateChanges.listen((firebaseUser) async {
        print("🔄 Auth state changed: ${firebaseUser?.email ?? 'null'}");
        if (!mounted) return;
        
        if (firebaseUser != null) {
          try {
            print("📊 Fetching user document for: ${firebaseUser.uid}");
            final user = await authService.getUserDocument(firebaseUser.uid);
            if (mounted) {
              if (user != null) {
                print("✅ User document found: ${user.name}");
                state = AsyncValue.data(user);
              } else {
                print("⚠️ No user document found, creating basic user");
                // If no user document exists, create a basic one from Firebase User
                final basicUser = UserModel(
                  id: firebaseUser.uid,
                  email: firebaseUser.email ?? '',
                  name: firebaseUser.displayName ?? 'User',
                  phoneNumber: firebaseUser.phoneNumber,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                state = AsyncValue.data(basicUser);
              }
            }
          } on Exception catch (e) {
            print("❌ Error fetching user document: $e");
            if (mounted) {
              state = AsyncValue.error(e, StackTrace.current);
            }
          }
        } else {
          print("👤 User signed out");
          if (mounted) {
            state = const AsyncValue.data(null);
          }
        }
      });

      // Get current user if available
      final currentUser = authService.currentUser;
      print("🚀 Initializing with current user: ${currentUser?.email ?? 'none'}");
      if (currentUser != null && mounted) {
        try {
          final user = await authService.getUserDocument(currentUser.uid);
          if (mounted) {
            if (user != null) {
              print("✅ Current user document found: ${user.name}");
              state = AsyncValue.data(user);
            } else {
              print("⚠️ No current user document found");
              state = const AsyncValue.data(null);
            }
          }
        } on Exception catch (e) {
          print("❌ Error fetching current user document: $e");
          if (mounted) {
            state = AsyncValue.error(e, StackTrace.current);
          }
        }
      } else {
        print("👤 No current user");
        if (mounted) {
          state = const AsyncValue.data(null);
        }
      }
    } catch (e) {
      print("❌ Error in auth init: $e");
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    if (!mounted) return;
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
      );
      // State will be updated through the auth state listener
    } on Exception catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    print("🔐 Starting sign in for: $email");
    if (!mounted) return;
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(authServiceProvider);
      print("🌐 Calling Firebase signIn...");
      await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("✅ Firebase signIn completed");
      // State will be updated through the auth state listener
    } on Exception catch (e) {
      print("❌ Sign in error: $e");
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> signOut() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (mounted) {
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(email);
    } on Exception {
      // For password reset, we don't update the main state
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String name,
    String? phoneNumber,
  }) async {
    final currentUser = state.value;
    if (currentUser == null || !mounted) return;

    try {
      state = const AsyncValue.loading();
      final authService = ref.read(authServiceProvider);
      
      final updatedUser = currentUser.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        updatedAt: DateTime.now(),
      );
      
      await authService.updateUserDocument(updatedUser);
      
      if (mounted) {
        state = AsyncValue.data(updatedUser);
      }
    } on Exception catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }
}

// Auth provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(AuthNotifier.new);
