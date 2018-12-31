require("babel-polyfill");
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database. 
const admin = require('firebase-admin');
const Storage = require('@google-cloud/storage');
const _ = require('lodash');
 


admin.initializeApp(functions.config().firebase);


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//

//Listen form ratings events
exports.onserveRating = functions.database.ref('/rating-sent/{uid}/{original}').onCreate(event =>{

    //let's log out some message
    var original = event.data.val();
    var fromUser = event.params.uid;
    
    const toUser = original.to;
    const rating = original.value;
    const postId = original.postId;
    const ratingId = event.params.original;
   
   
  
    return admin.database().ref('/users/' + toUser).once('value', snapshot =>{

        var toUserInfo = snapshot.val();
        var toUserToken = toUserInfo.fcmToken; 

        if(!toUserToken) return;
 
        var round = Math.floor(rating);
        
        var star = "⭐ ";
        var stars = ""
        
        for(var i = 0; i < round ; i += 1){
            stars +=star;
        }
 
        var textStart = rating > 1.5 ? "starts" : "star";
        

        return admin.database().ref('/users/' + fromUser).once('value', snapshot =>{

            var fromUserInfo = snapshot.val();
            var username = fromUserInfo.username

            var title = postId ? `${stars} you post has been rated!` : `${stars} you've been rated!`;
            var payload = {
                notification: {
                    title: title,
                    body: `${rating} ${textStart} by @${username}`,
                    sound: 'default',
                    badge: '1'
                },
                data: {
                    fromUserId: fromUser,
                    stars: rating.toString(),
                    postId: postId? postId : "" 
                }
            };

            admin.messaging().sendToDevice(toUserToken, payload)
            .then(function(response) {
              console.log("Successfully sent message:", response);
            }).catch(function(error) {
              console.log("Error sending message:", error);
            });

            //Add notification 
            var notificationPayload = {}
            if(postId){ //post was rated
              notificationPayload = {
                    "creationDate": {
                        ".sv": "timestamp"
                    },
                    "isNew": 1,
                    "fromUid": fromUser,
                    "postId": postId,
                    "type": "ratingPost"
                }
            }else{
             notificationPayload = {
                "creationDate": {
                    ".sv": "timestamp"
                },
                "isNew": 1,
                "ratingId": ratingId,
                "type": "userRating"
            }
        }
            return admin.database().ref(`/notifications/${toUser}`).push().set(notificationPayload);
        });
    });
});


//Listen form comments
exports.onserveComments = functions.database.ref('/comments/{postId}/{commentId}').onCreate(event =>{
    
        //let's log out some message
        var original = event.data.val();
        var postId = event.params.postId;
        var commentId = event.params.commentId;
        
        
        var comment = original.text;
        var fromUser = original.uid;

        console.log('comment " ' + comment + ' "   user: ' + fromUser );

        //Find post
        return admin.database().ref('/posts/' + postId).once('value', postSnap =>{

            var postInfo = postSnap.val();
            var toUser = postInfo.uid; //postOwner notify the user
            var postImage = postInfo.imageUrl;
            var postCaption = postInfo.caption;

            if(fromUser == toUser){ return }

    //userTo
        return admin.database().ref('/users/' + toUser).once('value', snapshot =>{
    
            var toUserInfo = snapshot.val();
            var toUserToken = toUserInfo.fcmToken; 
    
            if(!toUserToken) return;
     
    
            return admin.database().ref('/users/' + fromUser).once('value', snapshot =>{
    
                var fromUserInfo = snapshot.val();
                var username = fromUserInfo.username
    
                var payload = {
                    notification: {
                        title: `@${username} commented your photo`,
                        body: `${comment}`,
                        sound: 'default',
                        badge: '1'
                    },
                    data: {
                        fromUserId: fromUser,
                        commentId: commentId,
                        postId: postId,
                        photoUrl: postImage.toString()
                    }
                };
    
                admin.messaging().sendToDevice(toUserToken, payload)
                .then(function(response) {
                  console.log("Successfully sent message:", response);
                }).catch(function(error) {
                  console.log("Error sending message:", error);
                });

                const notificationPayload = {
                    "creationDate": {
                        ".sv": "timestamp"
                    },
                    "isNew": 1,
                    "postId": postId,
                    "commentId": commentId,
                    "type": "comment"
                } 
                return admin.database().ref(`/notifications/${toUser}`).push().set(notificationPayload);

            });
        });
    });
});


exports.sendPushNotification = functions.https.onRequest((request, response)=>{
    response.send("Attempting to send push notification");
    console.log("Trying to send push msg");


    //admin.messaging().sendToDevice(token, payload)

    // This registration token comes from the client FCM SDKs.
    var uid = 'L54Z6zk86EZabCbrwhjFt00buYo2';

    return admin.database().ref('/users/' + uid).once('value', snapshot => {
        var user = snapshot.val();
        console.log("User info"+ "username ="+ user.username + " and fcmtoken" + user.fcmToken);


        var payload = {
            notification: {
                title: `${user.username} rated you!`,
                body: "body over here in our msg body"
            }
        };
        
        admin.messaging().sendToDevice(user.fcmToken, payload)
          .then(function(response) {
            // See the MessagingDevicesResponse reference documentation for
            // the contents of response.
            console.log("Successfully sent message:", response);
          })
          .catch(function(error) {
            console.log("Error sending message:", error);
          });

    });

})



//Observe for remove posts
exports.onserveRemovePosts = functions.database.ref('/user-posts/{userId}/{postId}').onDelete(event =>{
    
        //let's log out some message
        var original = event.data.previous.val();
        var postId = event.params.postId;
        var userId = event.params.userId; 
        var fileName = original.fileName;
 

    //Removed from client side is faster
//        let postRef = admin.database().ref('/posts/'+postId);
//    
//        postRef.remove()
//        .then(function() {
//            console.log("on Posts removed succeeded.")
//        })
//        .catch(function(error) {
//                console.log("on Post Remove failed: " + error.message)
//        });
    
    
    
        let commentsRef = admin.database().ref('/comments/'+postId);
    
        commentsRef.remove()
        .then(function() {
            console.log("on Comments removed succeeded.")
        })
        .catch(function(error) {
                console.log("on Comments Remove failed: " + error.message)
        });
    
        
        if(fileName) { 
            
        const filePath = `${userId}/post/${fileName}`; 
        const storage = new Storage();
            
        const bucket = storage.bucket('nosedive-72b5b.appspot.com');
        const file = bucket.file(filePath);
 
        file.delete().then(() => {
            console.log(`Successfully deleted photo with UID: ${fileName}, userUID : ${userId}`);
        }).catch(err => {
            console.error(`Failed to remove photo, error: ${err}`);
        });
            
        }else{
            console.error('file name not found');
        }
    
    return commentsRef;
 
});


//Listen form ratings events
exports.onserveUpdateRating = functions.database.ref('/user-rating/{uid}/{ratingId}').onCreate(event =>{
    
        //let's log out some message
        var original = event.data.val();
        var userId = event.params.uid;
     
        return admin.database().ref('/user-rating/' + userId).once('value', snapshot =>{
    
            const ratings = snapshot.val();
             
            const starCounts = _.reduce(ratings, (result, value, key)=>{ 
                result[value.value] = (result[value.value]  || 0) + 1;
               return result
            }, {});
            
             
            const starMultiply =  Object.entries(starCounts).map(key =>key[0]*key[1]);  // 5*count, 4*count, 2*count .... 
            const starSum = Object.values(starMultiply).reduce((a,c)=> a + c);  				 //5*count + 4*count + 3*count ...
            const votes = Object.values(ratings).length; //sum of all votes
            const ratingCalculated = starSum/votes;
           
              return admin.database().ref('/users/'+ userId).update({ 'rating': ratingCalculated, 'votes': votes });
              console.log('rating updated',  ratingCalculated);
            
        });
    });


    //Listen form ratings events
exports.onserveUpdateRatingPost = functions.database.ref('/rating-posts/{postId}/{userId}').onCreate(event =>{
    
        //let's log out some message
        var original = event.data.val();
        var postId = event.params.postId;  
     
        return admin.database().ref('/rating-posts/' + postId ).once('value', snapshot =>{
    
            const ratings = snapshot.val();
            
            console.log("rating count" + ratings);
             
            const starCounts = _.reduce(ratings, (result, value, key)=>{ 
                result[value.value] = (result[value.value]  || 0) + 1;
               return result
            }, {});
            
             
            const starMultiply =  Object.entries(starCounts).map(key =>key[0]*key[1]);  // 5*count, 4*count, 2*count .... 
            const starSum = Object.values(starMultiply).reduce((a,c)=> a + c);  				 //5*count + 4*count + 3*count ...
            const votes = Object.values(ratings).length; //sum of all votes
            const ratingCalculated = starSum/votes;
            
           console.log('Rating per Post: ',  ratingCalculated, votes);
            
              return admin.database().ref('/posts/' + postId).once('value', postsnap =>{
                  var userId = postsnap.val().uid;
                 
                  if(userId){ 
                    return admin.database().ref('/posts/'+ postId).update({ 'rating': ratingCalculated, 'votes': votes }).then(()=>{
                        return admin.database().ref(`/user-posts/${userId}/${postId}`).update({ 'rating': ratingCalculated, 'votes': votes }); 
                    }).catch(err=>{
                        console.error('Error updating rating per post', err);
                    });
                  }
                }); 
             
        });
    });


 //Observe Following
exports.onserveFollowing = functions.database.ref('/following/{followerUser}/{followingUser}').onCreate(event =>{
    
        //let's log out some message
        //var original = event.data.val();
        var followerUser = event.params.followerUser;
        var followingUser = event.params.followingUser;
       
      
        return admin.database().ref('/users/' + followingUser).once('value', snapshot =>{
    
            var toUserInfo = snapshot.val();
            var toUserToken = toUserInfo.fcmToken; 
    
            if(!toUserToken) return;
     
    
            return admin.database().ref('/users/' + followerUser).once('value', snapshot =>{
    
                var fromUserInfo = snapshot.val();
                var username = fromUserInfo.username
                var star = "⭐";

                var payload = {
                    notification: {
                        title: `${star}You have new follower${star}`,
                        body: `@${username} started following you`,
                        sound: 'default',
                        badge: '1'
                    },
                    data: {
                        followerUser: followerUser, 
                    }
                };
    
                admin.messaging().sendToDevice(toUserToken, payload)
                .then(function(response) {
                  console.log("Successfully sent message:", response);
                }).catch(function(error) {
                  console.log("Error sending message:", error);
                });

                const notificationPayload = {
                    "creationDate": {
                        ".sv": "timestamp"
                    },
                    "isNew": 1,
                    "uid": followerUser,
                    "type": "follower"
                } 
                return admin.database().ref(`/notifications/${followingUser}`).push().set(notificationPayload);
            });
        });
    });


//Listen form new post and notify all followers
exports.onserveNewPost = functions.database.ref('/posts/{postId}').onCreate(event =>{
    
        //let's log out some message
        var original = event.data.val();
        var postId = event.params.postId;
        var userId = original.uid;
        var postCaption = original.caption;


        //find his followers

        return admin.database().ref('/followers/' + userId).once('value', fSnap =>{

            //1-get follower if
            var followers = fSnap.val(); 

            Object.keys(followers).forEach(function(follower) {
 
                
                return admin.database().ref('/users/' + follower).once('value', snapshot =>{
                    
                            var toUserInfo = snapshot.val();
                            var toUserToken = toUserInfo.fcmToken; 
                            
                    
                            if(!toUserToken) return;
                     
                    
                            return admin.database().ref('/users/' + userId).once('value', snapshot =>{
                    
                                var postOwner = snapshot.val();

                                var payload = {
                                    notification: {
                                        title: `@${postOwner.username} posted a new photo`,
                                        body: `${postCaption}`,
                                        sound: 'default',
                                        badge: '1'
                                    },
                                    data: {
                                        postId: postId, 
                                    }
                                };
                    
                                admin.messaging().sendToDevice(toUserToken, payload)
                                .then(function(response) {
                                  console.log("Successfully sent message:", response);
                                }).catch(function(error) {
                                  console.log("Error sending message:", error);
                                });
                            });
                        });

            }, this);
 

        });
});