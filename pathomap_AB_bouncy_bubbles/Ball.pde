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

  void stop_ignoring(){
    ignore = false;
  }

  void set_x(float xin){
    x = xin;
    vx = 0;
  }

  void set_y(float yin){
    y = yin;
    vy = 0;
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
      float minDist = others[i].diameter + diameter;
      if (distance < minDist) { 
        // THIS IS A COLLISION EVENT - SEND OSC SOUND NOW?
        if (isrightHand == true || isleftHand == true){
//           oscP5.send(hand_message, myRemoteLocation); 
        }
        else{
//            oscP5.send(collide_message, myRemoteLocation); 
        }
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

    boolean bounce = false;

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
          bounce = true;

        }
        //bounce off left border
        else if (x - diameter/2 < 0) {
          x = diameter/2;
          vx *= friction;
          bounce = true;

        }
        //bounce off ceiling
        else if (y - diameter/2 < 0) {
          y = diameter/2;
          vy *= friction;
          bounce = true;

        }
      }

      //bottomleft

      else if(y > wall_y && x < wall_x){

        //bounce off left border
        if (x - diameter/2 < 0) {
          x = diameter/2;
          vx *= friction;
          bounce = true;
        }

        //bounce off floor
        if (y + diameter/2 > height) {
          y = height - diameter/2;
          vy *= friction; 
          bounce = true;

        } 

        //bounce off wall to the right
        if (x + diameter/2 > wall_x) {
          x = wall_x - diameter/2;
          vx *= friction; 
          bounce = true;

        }

      } 

      //bottom right

      else if (y > wall_y && x > wall_x){

        //bounce off right border
        if (x + diameter/2 > width) {
          x = width - diameter/2;
          vx *= cheat_friction; 
          bounce = true;

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
             
             if (!ignore){
              num_ignored_balls += 1;
              oscP5.send(disappear_message, myRemoteLocation); 


             }

             ignore = true;

            
          }
          
        }

        //bounce off wall to the left
        if (x - diameter/2 < wall_x) {
          x = wall_x + diameter/2;
          vx *= friction; 
          bounce = true;

        }

      }
      else{
        println("error location");
      }
    }

  if (bounce && !ignore){
    oscP5.send(bounce_message, myRemoteLocation);
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
