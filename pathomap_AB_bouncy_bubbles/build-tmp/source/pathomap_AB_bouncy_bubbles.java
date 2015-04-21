import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class pathomap_AB_bouncy_bubbles extends PApplet {

int numBalls;
float spring = 0.02f;
float gravity = 0.03f;
float friction = -0.2f;
Ball[] balls;
PImage background_img;

float wall_x;
float wall_y;

public void setup() {
//  size(768, 600);
  size(635, 476);
  // size(displayWidth, displayHeight);
  //read lines in file into array of strings
  String[] lines = loadStrings("DataTable2b-MetaPhLan-ABonly.genus.sum_all_samples.gt0.BactOnly.gt10.nicenames.txt");
  background_img = loadImage("AB_station_collage.jpg");
  // background_img.resize(displayWidth, displayHeight);
  //will have one extra ball for the mouse
  numBalls = lines.length + 1;
//  print(numBalls);
  balls = new Ball[numBalls];
  
  int mouseColor = color(0, 0, 0);
  
  //make the first ball the mouse ball
  balls[0] = new Ball(mouseX, mouseY, 100, 0, balls, "mouse", mouseColor);
  balls[0].setAsMouse();
  
  for (int i = 0; i < numBalls - 1; i++) {
    String[] line = split(lines[i], " ");
    
    float radius = PApplet.parseFloat(line[1]);
    radius = log(radius) * 10;
    
    String name = line[0];
    
    float r = random(0, 255);
    float g = random(0, 255);
    float b = random(0, 255);
    
    int c = color(r, g, b);
    
    balls[i+1] = new Ball(random(width), height - 10, radius, i+1, balls, name, c);
//    println(i+1, name);
  }
  noStroke();
//  fill(255, 204);
  image(background_img, 0, 0);


  wall_x = (float)width * 0.75f;
  wall_y = (float)height * 0.5f;
  println(wall_x, wall_y);
}

public void draw() {
//  background(0);
  image(background_img, 0, 0);

  // println(wall_x, wall_y);

  fill(255, 0, 0);
  rect(wall_x, wall_y, 10, height - wall_y);
  // ellipse(wall_x, wall_y, 20, 20);
  for (Ball ball : balls) {
    ball.collide();
    ball.move();
    ball.display();  
  }
//  saveFrame("frames/frame#####.tga");
  
}

class Ball {
  
  float x, y;
  float diameter;
  float vx = 0;
  float vy = 0;
  int id;
  Ball[] others;
  String name;
  Boolean isMouse;
  int c;
 
  Ball(float xin, float yin, float din, int idin, Ball[] oin, String namein, int cin) {
    x = xin;
    y = yin;
    diameter = din;
    id = idin;
    others = oin;
    name = namein;
    isMouse = false;
    c = cin;
  } 
  
  public void setAsMouse(){
   isMouse = true; 
  }
  
  public void collide() {
//    println("colliding", id);
    for (int i = id + 1; i < numBalls; i++) {
//      print(i, " " );
      float dx = others[i].x - x;
      float dy = others[i].y - y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = others[i].diameter/2 + diameter/2;
      if (distance < minDist) { 
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
  
  public void move() {
    
    if(isMouse == false){
      vy += gravity;
      x += vx;
      y += vy;

      //interaction of the ball with the frame. 
      // 

      //top
      if ( y < wall_y){

        //bounce off right border
        if (x + diameter/2 > width) {
          x = width - diameter/2;
          vx *= friction; 
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
          vx *= friction; 
        }

        //bounce off floor with no spring
        if (y + diameter/2 > height) {
          y = height - diameter/2;
          vy *= friction; 
        }

        if (x - diameter/2 < wall_x) {
          x = wall_x + diameter/2;
          vx *= friction; 
        }

      }
      else{
        println("error location");
      }
    }

    else{
      x = mouseX;
      y = mouseY;
    }
  }
  
  public void display() {
    if(isMouse == false){
      
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "pathomap_AB_bouncy_bubbles" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
