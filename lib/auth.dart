import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService{

 FirebaseUser fbuser;


final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _firebaseAuth =FirebaseAuth.instance;
final Firestore _db = Firestore.instance;
 
Observable<FirebaseUser> user;  //firebase user
Observable<Map<String, dynamic>> profile; //custom data in firestore
PublishSubject loading = PublishSubject();

//constructor
AuthService(){
  user = Observable (_firebaseAuth.onAuthStateChanged);

  profile = user.switchMap((FirebaseUser u) {
    if(u != null){
      return _db.collection('Users').document(u.uid).snapshots().map((snap) => snap.data);
    }
    else{
      return Observable.just({});
    }
  });
}


Future<FirebaseUser> googleSignIn() async {
  loading.add(true);
  GoogleSignInAccount googleUser = await _googleSignIn.signIn(); 
  GoogleSignInAuthentication googleAuth=await googleUser.authentication;
  fbuser = await _firebaseAuth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken 
  );


  updateUserData(fbuser);

  print("signed in as " + fbuser.displayName);
  



  loading.add(false);
  return fbuser;

}


void updateUserData(FirebaseUser user) async {

  //Writing data to Firestore
  DocumentReference ref = _db.collection('Users').document(user.uid);


  return ref.setData({
    'uid': user.uid,
    'email': user.email,
    'photoURL': user.photoUrl,
    'displayName': user.displayName,
    'lastSeen': DateTime.now()
  },merge: true);

}


void signOut(){
  _firebaseAuth.signOut();
  print('Signed Out');
}


}

final AuthService authService = AuthService();