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
    
    balls[i] = new Ball(random(width),  10, radius, i+1, balls, name, c);
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

 
 
  

//////////// DRAW BACKGOUND IMAGE //////////////
if (showImage){
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

///////////// END DRAW KINECT IMAGE //////////
  // println(wall_x, wall_y);

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
//  saveFrame("frames/frame#####.tga");
  
}

 //Draw Circle on Head
 void circleHead(int userId){
   // get 3D position of head
  
  
  
  //
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




class Ball {
  
  float x, y;
  float diameter;
  float vx = 0;
  float vy = 0;
  int id;
  Ball[] others;
  String name;
  Boolean isMouse;
  Boolean isleftHand;
  Boolean isrightHand;
  color c;
  Boolean ignore;
 
  Ball(float xin, float yin, float din, int idin, Ball[] oin, String namein, color cin) {
    x = xin;
    y = yin;
    diameter = din;
    id = idin;
    others = oin;
    name = namein;
    isMouse = false;
    isleftHand = false;
    isrightHand = false;
    ignore = false;
    c = cin;
    
  } 
  void ignore(){
  ignore = true;  
  }
  
  void setAsMouse(){
   isMouse = true; 
  }
    void setAsrightHand(){
   isrightHand = true; 
  }
    void setAsleftHand(){
   isleftHand = true; 
  }
  
  
  void collide() {
//    println("colliding", id);
    for (int i = id + 1; i < numBalls; i++) {
//      print(i, " " );
      float dx = others[i].x - x;
      float dy = others[i].y - y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = others[i].diameter/2 + diameter/2;
      if (distance < minDist) { 
        // THIS IS A COLLISION EVENT - SEND OSC SOUND NOW?
        float angle = atan2(dy, dx);
        float targetX = x + cos(angle) * minDist;
        float targetY = y + sin(angle) * minDist;
        float ax = (targetX - others[i].x) * spring;
        float ay = (targetY - others[i].y) * spring;
        vx -= ax;
        vy -= ay;
        others[i].vx += ax;
        others[i].vy += ay;
      }
    }   
  }
  

  
 
  void move() {
     if(isMouse==true){
      x = mouseX;
      y = mouseY;
    }
   
     else if(isleftHand==true){
      x = (leftHand.x * scaling_factor_x);
      y = (leftHand.y * scaling_factor_y);
     }
     
     else if(isrightHand==true){
      x= (rightHand.x * scaling_factor_x);
      y = (rightHand.y * scaling_factor_y);
     }
    
    else if(isMouse==false){
      vy += gravity;
      x += vx;
      y += vy;

      //interaction of the ball with the frame. 
      // the frame is divided into three sections: 
      // top (above the "wall" defining the border of the container)
      // bottom left: to the left of the wall
      // bottom right: to the right of the wall

      //top
      if ( y < wall_y){

        //COLLISION EVENTS WITH FRAME: SEND OSC MESSAGE FOR SOUND? 
        //bounce off right border
        if (x + diameter/2 > width) {
          x = width - diameter/2;
          vx *= cheat_friction; 
        }
        //bounce off left border
        else if (x - diameter/2 < 0) {
          x = diameter/2;
          vx *= friction;
        }
        //bounce off ceiling
        else if (y - diameter/2 < 0) {
          y = diameter/2;
          vy *= friction;
        }
      }

      //bottomleft

      else if(y > wall_y && x < wall_x){

        //bounce off left border
        if (x - diameter/2 < 0) {
          x = diameter/2;
          vx *= friction;
        }

        //bounce off floor
        if (y + diameter/2 > height) {
          y = height - diameter/2;
          vy *= friction; 
        } 

        //bounce off wall to the right
        if (x + diameter/2 > wall_x) {
          x = wall_x - diameter/2;
          vx *= friction; 
        }

      } 

      //bottom right

      else if (y > wall_y && x > wall_x){

        //bounce off right border
        if (x + diameter/2 > width) {
          x = width - diameter/2;
          vx *= cheat_friction; 
        }

        //bounce off floor with no spring
        //DISSAPPEAR
        if (y + diameter/2 > height) {
          //start just bounce dont disappear
          // y = height - diameter/2;
          // vy *= friction; 
         
          //end just bounce dont disappear
          
          //start disappear
         if (!isMouse && !isleftHand && !isrightHand){
             ignore = true;
            
          }
          
        }

        //bounde off wall to the left
        if (x - diameter/2 < wall_x) {
          x = wall_x + diameter/2;
          vx *= friction; 
        }

      }
      else{
        println("error location");
      }
    }

 
  }
  
  void display() {
    if( !(isMouse || ignore)){
      
      float alpha = 0;
      if( y > height / 4 && y < height/2){
        alpha = map(y, height / 4, height/2, 0, 255);
      }
      if(y > height / 2 && y < (height / 4) * 3 ) {
        alpha = map(y, height/2, (height / 4) * 3 , 255, 0); 
      }

//      alpha = map(y, 0, height, 255, 0);
      
      fill(c, 204);
      ellipse(x, y, diameter, diameter);
      textSize(24);
      fill(c, alpha);
      textAlign(CENTER, CENTER);
      text(name, x, y);
    }
  }
}


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

