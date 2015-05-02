// the ControlFrame class extends PApplet, so we 
// are creating a new processing applet inside a
// new frame with a controlP5 object loaded
public class ControlFrame extends PApplet {

  int w, h;

  int abc = 100;
  
  public void setup() {
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);
    cp5.addSlider("abc").setRange(0, 255).setPosition(10,10);
    cp5.addSlider("back").plugTo(parent,"back").setRange(0, 255).setPosition(10,30);
    cp5.addSlider("showKinect").plugTo(parent,"showKinect").setRange(0, 1).setPosition(10,40);

      // create a toggle and change the default look to a (on/off) switch look
    // cp5.addToggle("showKinect").plugTo(parent, "showKinect").setPosition(10,40).setValue(false).setMode(ControlP5.SWITCH);       ;
  }

  public void draw() {
      background(abc);
  }
  
  private ControlFrame() {
  }

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }


  public ControlP5 control() {
    return cp5;
  }
  
  
  ControlP5 cp5;

  Object parent;

  
}