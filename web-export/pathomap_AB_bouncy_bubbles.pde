int numBalls;
float spring = 0.02;
float gravity = 0.03;
float friction = -0.2;
Ball[] balls;
PImage background;

void setup() {
//  size(768, 600);
  size(635, 476);
  //read lines in file into array of strings
  String[] lines = loadStrings("DataTable2b-MetaPhLan-ABonly.genus.sum_all_samples.gt0.BactOnly.gt10.nicenames.txt");
  background = loadImage("AB_station_collage.jpg");
  //will have one extra ball for the mouse
  numBalls = lines.length + 1;
//  print(numBalls);
  balls = new Ball[numBalls];
  
  color mouseColor = color(0, 0, 0);
  
  //make the first ball the mouse ball
  balls[0] = new Ball(mouseX, mouseY, 100, 0, balls, "mouse", mouseColor);
  balls[0].setAsMouse();
  
  for (int i = 0; i < numBalls - 1; i++) {
    String[] line = split(lines[i], " ");
    
    float radius = float(line[1]);
    radius = log(radius) * 10;
    
    String name = line[0];
    
    float r = random(0, 255);
    float g = random(0, 255);
    float b = random(0, 255);
    
    color c = color(r, g, b);
    
    balls[i+1] = new Ball(random(width), height - 10, radius, i+1, balls, name, c);
//    println(i+1, name);
  }
  noStroke();
//  fill(255, 204);
  image(background, 0, 0);
}

void draw() {
//  background(0);
  image(background, 0, 0);
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
  color c;
 
  Ball(float xin, float yin, float din, int idin, Ball[] oin, String namein, color cin) {
    x = xin;
    y = yin;
    diameter = din;
    id = idin;
    others = oin;
    name = namein;
    isMouse = false;
    c = cin;
  } 
  
  void setAsMouse(){
   isMouse = true; 
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
    
    if(isMouse == false){
      vy += gravity;
      x += vx;
      y += vy;
      if (x + diameter/2 > width) {
        x = width - diameter/2;
        vx *= friction; 
      }
      else if (x - diameter/2 < 0) {
        x = diameter/2;
        vx *= friction;
      }
      if (y + diameter/2 > height) {
        y = height - diameter/2;
        vy *= friction; 
      } 
      else if (y - diameter/2 < 0) {
        y = diameter/2;
        vy *= friction;
      }
    }
    else{
      x = mouseX;
      y = mouseY;
    }
  }
  
  void display() {
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

