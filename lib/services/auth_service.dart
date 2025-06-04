import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart' as app;

class AuthService with ChangeNotifier {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  app.User? _user;
  bool _isLoading = false;
  String? _error;

  app.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((firebase.User? firebaseUser) async {
      if (firebaseUser != null) {
        await _fetchUserData(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (docSnapshot.exists) {
        _user = app.User.fromJson({
          'id': uid,
          ...docSnapshot.data()!,
        });
      } else {
        final firebaseUser = _auth.currentUser!;
        _user = app.User(
          id: uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
          photoUrl: firebaseUser.photoURL,
          isEmailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
        );

        // Create the user document
        await _firestore.collection('users').doc(uid).set(_user!.toJson());
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmail(String email, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(displayName);

      return true;
    } on firebase.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return true;
    } on firebase.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Sign out first to make sure we get the account picker
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Log out first
      await FacebookAuth.instance.logOut();
      
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final firebase.AuthCredential credential = 
            firebase.FacebookAuthProvider.credential(accessToken.token);
            
        await _auth.signInWithCredential(credential);
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _user = null;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        if (displayName != null) {
          await currentUser.updateDisplayName(displayName);
        }
        
        if (photoUrl != null) {
          await currentUser.updatePhotoURL(photoUrl);
        }
        
        // Update Firestore document
        await _firestore.collection('users').doc(currentUser.uid).update({
          if (displayName != null) 'displayName': displayName,
          if (photoUrl != null) 'photoUrl': photoUrl,
        });
        
        // Refresh user data
        await _fetchUserData(currentUser.uid);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveEvent(String eventId) async {
    if (_user == null) return false;
    
    try {
      final updatedSavedEvents = [..._user!.savedEvents];
      
      if (!updatedSavedEvents.contains(eventId)) {
        updatedSavedEvents.add(eventId);
      }
      
      await _firestore.collection('users').doc(_user!.id).update({
        'savedEvents': updatedSavedEvents
      });
      
      _user = _user!.copyWith(savedEvents: updatedSavedEvents);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unsaveEvent(String eventId) async {
    if (_user == null) return false;
    
    try {
      final updatedSavedEvents = _user!.savedEvents.where((id) => id != eventId).toList();
      
      await _firestore.collection('users').doc(_user!.id).update({
        'savedEvents': updatedSavedEvents
      });
      
      _user = _user!.copyWith(savedEvents: updatedSavedEvents);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool isEventSaved(String eventId) {
    if (_user == null) return false;
    return _user!.savedEvents.contains(eventId);
  }
  
  void _handleAuthException(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        _error = 'Invalid email or password';
        break;
      case 'email-already-in-use':
        _error = 'Email already in use';
        break;
      case 'weak-password':
        _error = 'Password is too weak';
        break;
      case 'invalid-email':
        _error = 'Invalid email address';
        break;
      default:
        _error = e.message ?? 'An unknown error occurred';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}