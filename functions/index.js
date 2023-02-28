
const functions = require('firebase-functions');
const admin = require("firebase-admin");
admin.initializeApp();

exports.onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context) => {
    console.log("Follower Created", snapshot.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // 1) Create followed users posts ref
    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("userPosts");

    const StoryFollower = admin
      .firestore()
      .collection("story")
      .doc(userId)
      .collection("userstory");

    // 2) Create following user's timeline ref
    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    ////
    const timelineStoryRef = admin
      .firestore()
      .collection("Storytimeline")
      .doc(followerId)
      .collection("timelineStory");

    // 3) Get followed users posts
    const querySnapshot = await followedUserPostsRef.get();

    const storysnapshot = await StoryFollower.get();




    // 4) Add each user post to following user's timeline
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostsRef.doc(postId).set(postData);
      }
    });

    storysnapshot.forEach(doc => {
      if (doc.exists) {
        const postId = doc.id;
        const StoryData = doc.data();
        timelineStoryRef.doc(postId).set(StoryData);
      }
    }
    );
  });

exports.onDeleteFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snapshot, context) => {
    console.log("Follower Deleted", snapshot.id);

    const userId = context.params.userId;
    const followerId = context.params.followerId;

    ////For Post Remove//////

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("ownerId", "==", userId);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });

    ////For Story Remove//////


    const StorytimelineRef = admin
      .firestore()
      .collection("Storytimeline")
      .doc(followerId)
      .collection("timelineStory")
      .where("ownerId", "==", userId);

    const StroySnapshot = await StorytimelineRef.get();
    StroySnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

// when a post is created, add post to timeline of each follower (of post owner)
exports.onCreatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Add new post to each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(postCreated);

    });
  });


exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Update each post in each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
    });
  });

exports.onDeletePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Delete each post in each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });


//////////////////////////////////////////Stoory POst And Update  //////////////////////

exports.onCreateStoryss = functions.firestore
  .document("/story/{userId}/userstory/{postId}")
  .onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Add new post to each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("Storytimeline")
        .doc(followerId)
        .collection("timelineStory")
        .doc(postId)
        .set(postCreated);

    });
  });

  


exports.onUpdateStory = functions.firestore
  .document("/story/{userId}/userstory/{postId}")
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Update each post in each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("Storytimeline")
        .doc(followerId)
        .collection("timelineStory")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
    });
  });





















// exports.onCreateStorys = functions.firestore
//   .document("/story/{userId}")
//   .onCreate(async (snapshot, context) => {
//     const StoryCreated = snapshot.data();
//     const userId = context.params.userId;

//     // 1) Get all the followers of the user who made the post
//     const userFollowersRef = admin
//       .firestore()
//       .collection("followers")
//       .doc(userId)
//       .collection("userFollowers");

//     const querySnapshot = await userFollowersRef.get();
//     // 2) Add new post to each follower's timeline
//     querySnapshot.forEach(doc => {
//       const followerId = doc.id;

//       admin
//         .firestore()
//         .collection("Storytimeline")
//         .doc(followerId)
//         .collection("timelineStory")
//         .doc(userId)
//         .set(StoryCreated);

//     });
//   });


// exports.onUpdateStory = functions.firestore
//   .document("/story/{userId}")
//   .onUpdate(async (change, context) => {
//     const StoryUpdated = change.after.data();
//     const userId = context.params.userId;

//     // 1) Get all the followers of the user who made the post
//     const userFollowersRef = admin
//       .firestore()
//       .collection("followers")
//       .doc(userId)
//       .collection("userFollowers");

//     const querySnapshot = await userFollowersRef.get();
//     // 2) Update each post in each follower's timeline
//     querySnapshot.forEach(doc => {
//       const followerId = doc.id;

//       admin
//         .firestore()
//         .collection("Storytimeline")
//         .doc(followerId)
//         .collection("timelineStory")
//         .doc(userId)
//         .get()
//         .then(doc => {
//           if (doc.exists) {
//             doc.ref.update(StoryUpdated);
//           }
//         });
//     });
//   });


