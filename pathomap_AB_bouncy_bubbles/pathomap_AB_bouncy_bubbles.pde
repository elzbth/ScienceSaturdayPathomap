import SimpleOpenNI.*;
int numBalls;
int maxUsers = 1;
float spring = 0.02;
float gravity = 0.03;
float cheat_friction = -0.2;
float friction = -1;
Ball[] balls;
PImage background_img;
PImage test_tube;

//gamification variables
int num_ignored_balls = 0;
int time_to_wait; 


float wall_x;
float wall_y;

// Begin Kinect Variables - create kinect object
SimpleOpenNI  kinect;
// image storage from kinect
PImage kinectDepth;

PImage kinectDepth_resize;
// int of each user being  tracked
int[] userID;
// user colors
color[] userColor = new color[]{ color(255,0,0), color(0,255,0), color(0,0,255),
                                 color(255,255,0), color(255,0,255), color(0,255,255)};

PVector leftHand = new PVector(0,0,0);
PVector rightHand = new PVector(0,0,0);
// turn headPosition into scalar form
float distanceScalarL;
float distanceScalarR;
// diameter of head drawn in pixels
float headSize = 200;
 
// threshold of level of confidence
float confidenceLevel = 0.5;
// the current confidence level that the kinect is tracking
float confidence;
// vector of tracked head for confidence checking
PVector confidenceVector = new PVector();

//scaling factor for x pos of kinect
float scaling_factor_x = 1.5;

//scaling factor for y pos of kinect
float scaling_factor_y = 1.5;


float kinect_width = 640;
float kinect_height = 480;

Boolean showKinect = true;
Boolean showImage = false;


void setup() {


   // size(768, 600);
  // size(640, 480);

  size(displayWidth, displayHeight - 50);

  scaling_factor_x =  width / kinect_width;
  scaling_factor_y =  height / kinect_height;

  println(scaling_factor_x, scaling_factor_y);


    ////////////////////initialize kinect ////////////////////////
  // start a new kinect object
  kinect = new SimpleOpenNI(this);
  // enable depth sensor
  kinect.enableDepth();
  //Mirror to match real world
  kinect.setMirror(true);
  // enable skeleton generation for all joints
  kinect.enableUser();
  /////////////////////////////////////////////////////////////////
  // // draw thickness of drawer
  strokeWeight(3);
  // smooth out drawing
  smooth();

  
  /////////////////////////// read data ///////////////////////////////
  //read lines in file into array of strings
  String[] lines = loadStrings("DataTable2b-MetaPhLan-ABonly.genus.sum_all_samples.gt0.BactOnly.gt10.nicenames.txt");
  background_img = loadImage("AB_station_collage.jpg");
  background_img.resize(width, height);

  test_tube = loadImage("testubeorange.png");
  test_tube.resize(int(width * 0.25), int(height * 0.5));


  ///////////////////////////////////////////////////////////////////
  

  
  
  //will have one extra ball for the mouse, and one for each hand
  numBalls = lines.length + 3;
//  print(numBalls);
  balls = new Ball[numBalls];
  
  color mouseColor = color(0, 0, 0);
  
  //make the last ball the mouse ball
  balls[numBalls - 1] = new Ball(mouseX, mouseY, 100, 0, balls, "mouse", mouseColor);
  balls[numBalls -1].setAsMouse();
   //********* add balls for Kinect
  balls[numBalls - 2] = new Ball(leftHand.x, leftHand.y, 100, 1, balls, "lefthand", mouseColor);
  balls[numBalls - 2].setAsleftHand();
   balls[numBalls - 3] = new Ball(rightHand.x, rightHand.y, 100, 2, balls, "righthand", mouseColor);
  balls[numBalls - 3].setAsrightHand();
  
  
  for (int i = 0; i < numBalls - 3; i++) {
    String[] line = split(lines[i], " ");
    
    float radius = float(line[1]);
    radius = log(radius) * 10;
    
    String name = line[0];
    
    float r = random(0, 255);
    float g = random(0, 255);
    float b = random(0, 255);
    
    color c = color(r, g, b);
    
    balls[i] = new Ball(random(width * 0.75),  10, radius, i+1, balls, name, c);
//    println(i+1, name);
  }
  noStroke();
//  fill(255, 204);
  //image(background_img, 0, 0);


  wall_x = (float)width * 0.75;
  wall_y = (float)height * 0.5;
  println("wall:", wall_x, wall_y);
}


  
void draw(){


  
  /*---------------------------------------------------------------
Updates Kinect. Gets users tracking and draws skeleton and
head if confidence of tracking is above threshold
----------------------------------------------------------------*/
  // update the camera
  kinect.update();
  // get Kinect data
  kinectDepth = kinect.depthImage();
  // kinectDepth_resize = kinect.depthImage();
  // kinectDepth.resize(width, height);
  // draw depth image at coordinates (0,0)
  //image(kinectDepth,0,0); 
 
   // get all user IDs of tracked users
  userID = kinect.getUsers();
 
  // loop through each user to see if tracking
  for(int i=0;i<userID.length;i++)
  {
    // if Kinect is tracking certain user then get joint vectors
    if(kinect.isTrackingSkeleton(userID[i]))
    {
      // get confidence level that Kinect is tracking head
      confidence = kinect.getJointPositionSkeleton(userID[i],
                          SimpleOpenNI.SKEL_HEAD,confidenceVector);
 
      // if confidence of tracking is beyond threshold, then track user
      if(confidence > confidenceLevel)
      {
        // change draw color based on hand id#
        //stroke(userColor[(i)]);
        // fill the ellipse with the same color
        fill(userColor[(i)]);
        // detect hand coordinates
        kinect.getJointPositionSkeleton(userID[i], SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
        kinect.getJointPositionSkeleton(userID[i], SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
        // convert real world point to projective space
        kinect.convertRealWorldToProjective(leftHand,leftHand);
        kinect.convertRealWorldToProjective(rightHand,rightHand);
        // create a distance scalar related to the depth in z dimension
        distanceScalarL = (525 / leftHand.z);
        distanceScalarR = (525 / rightHand.z);
        // draw the circle at the position of the head with the head size scaled by the distance scalar
        // fill (0,255,0);
        // ellipse(leftHand.x * scaling_factor_x,leftHand.y * scaling_factor_y, 50, 50);
        
        // fill (0,255,0);
        // ellipse(rightHand.x * scaling_factor_x, rightHand.y * scaling_factor_y, 50, 50);
        // println("leftHand:", leftHand.x, "," , leftHand.y);
        // println("rightHand:", rightHand.x, "," , rightHand.y);
       
      } //if(confidence > confidenceLevel)
    } //if(kinect.isTrackingSkeleton(userID[i]))
  } //for(int i=0;i<userID.length;i++)

 
 
  

if (showImage){
  //////////// DRAW BACKGOUND IMAGE //////////////

  image(background_img, 0, 0);
}
else if (showKinect){
///////////// DRAW KINECT IMG //////////////
  // // draw thickness of drawer
  // strokeWeight(3);
  // // smooth out drawing
  // smooth();

  background(0);


  image(kinectDepth, 0, 0);

}
image(test_tube, wall_x, wall_y);

//waiting in between games
if (millis() < time_to_wait){
    
    println("waiting");
    fill(255, 0, 0);
    text("YOU WON", width/2, height/2);
}

//playing 
else{

  fill(255, 0, 0);
  rect(wall_x, wall_y, 10, height - wall_y);
  // ellipse(wall_x, wall_y, 20, 20);
  for (Ball ball : balls) {
    if (ball != null){
      ball.collide();
      ball.move();
      ball.display();  
    }
  }


  println(num_ignored_balls, numBalls);
  if (num_ignored_balls == numBalls - 3){
  // if (true){
    time_to_wait = millis() + 5000;

    for (Ball ball : balls) {
      if (ball != null){
        ball.set_x(random(0,width * 0.75));
        ball.set_y(10);
        ball.stop_ignoring();
      }
    num_ignored_balls = 0;
    }
  }
}
//  saveFrame("frames/frame#####.tga");

  
}


  /*---------------------------------------------------------------
When a new user is found, print new user detected along with
userID and start pose detection.  Input is userID
----------------------------------------------------------------*/
void onNewUser(SimpleOpenNI curContext, int userId){
  println("New User Detected - userId: " + userId);
  // start tracking of user id
  kinect.startTrackingSkeleton(userId);
  //curContext.startTrackingSkeleton(userId);
} //void onNewUser(SimpleOpenNI curContext, int userId)
 
/*---------------------------------------------------------------
Print when user is lost. Input is int userId of user lost
----------------------------------------------------------------*/
void onLostUser(SimpleOpenNI curContext, int userId){
  // print user lost and user id
  println("User Lost - userId: " + userId);
} //void onLostUser(SimpleOpenNI curContext, int userId)
 
/*---------------------------------------------------------------
Called when a user is tracked.
----------------------------------------------------------------*/
void onVisibleUser(SimpleOpenNI curContext, int userId){
} //void onVisibleUser(SimpleOpenNI curContext, int userId)




void keyPressed() {
  if (key == ESC ) {
    exit();
  } else if (key == 'k') {
    showKinect = true;
    showImage = false;
  }
  else if (key == 'i'){
    showImage = true;
    showKinect = false;
  }
}

