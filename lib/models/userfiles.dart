import 'package:cloud_firestore/cloud_firestore.dart';

//This Model Takes In A Snapshot And Returns A User Object
//If this were a stateful widget this would be in the
// widget location
class GUser {
  final String? fname;
  final String? lname;
  final String? rate;
  final String? ratevalue;
  final int? no_rate_ppl;
  final String? bio;
  final String? address;
  final String? occupation;
  final String? works_at;
  final String? street_name;
  final String? email;
  final String? city;
  final String? phone1;
  final String? phone2;
  final String? profilePhotoUrl;
  final String? identify_as;
  final String? backprofilePhotoUrl;
  final String? id;


  GUser({
    this.fname,
    this.lname,
    this.rate,
    this.ratevalue,
    this.no_rate_ppl,
    this.address,
    this.city,
    this.phone1,
    this.phone2,
    this.occupation,
    this.email,
    this.profilePhotoUrl,
    this.identify_as,
    this.backprofilePhotoUrl,
    this.id,
    this.bio,
    this.works_at,
    this.street_name,
  });

  //From Firestore A DocumentSnapshot. Doc Is A Map.
  // This Is A From Document Factory
  factory GUser.fromDocument(DocumentSnapshot snapshot) {
    return GUser(
      id: snapshot['Id'],
      email: snapshot['Email'],
      fname: snapshot['First Name'],
      city: snapshot['City'],
      phone1: snapshot['Contact 1'],
      phone2: snapshot['Contact 2'],
      lname: snapshot['Last Name'],
      rate: snapshot['Rating'],
      ratevalue: snapshot['Rating_value'],
      no_rate_ppl: snapshot['No_ppl_rated'],
      profilePhotoUrl: snapshot['ProfilePhotoUrl'],
      backprofilePhotoUrl: snapshot['BackProfilePhotoUrl'],
      bio: snapshot['Bio'],
      works_at: snapshot['Works_at'],
      identify_as: snapshot['Identify_as'],
      street_name: snapshot['Street name'],
    );
  }





}
class PostPhotos{
  final String? f_postPhoto;
  final String? s_postPhoto;
  final String? t_postPhoto;

  PostPhotos({
    this.f_postPhoto,
    this.s_postPhoto,
    this.t_postPhoto,
  });

  /*factory postPhotos.fromDocument(DocumentSnapshot snapshot) {
    return postPhotos(
     f_postPhoto: snapshot['MediaUrl'],
     s_postPhoto: snapshot['F_PostPhoto'],
     t_postPhoto: snapshot['S_PostPhoto'],
    );
  }
*/
}
class Review {
  final String? content;
  final String? to;
  final String? from;
  final String? reviewId;
  final String? time;

  Review({
    this.content,
    this.to,
    this.from,
    this.reviewId,
    this.time,

  });

  factory Review.fromDocument(DocumentSnapshot doc) {
    return Review(
      content: doc['Content'],
      time: doc['Time'],
      reviewId: doc['Review_ID'],
      from: doc['From'],
      to: doc['To'],
    );
  }
}


class U_rate {
  String? rating;
  String? rated_By;



  U_rate({
    this.rating,
    this.rated_By,

  });

  //From Firestore A DocumentSnapshot. Doc Is A Map.
  // This Is A From Document Factory
  factory U_rate.fromDocument(DocumentSnapshot snapshot) {
    return U_rate(
      rating: snapshot['Rating'],
      rated_By: snapshot['Rated_By'],
    );
  }





}