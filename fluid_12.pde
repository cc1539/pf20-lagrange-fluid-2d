import java.util.*;

World world;

boolean running = true;
int part_type;

public static PApplet applet;

void setup() {
  applet = this;
  
  size(640,480);
  noSmooth();
  
  float tile_size = 12;
  world = new World(
      ceil(width/tile_size),
      ceil(height/tile_size),
      tile_size);
  world.randomizeProperties();
}

void keyPressed() {
  switch(key) {
    case 'c':{ 
      world.clear();
    } break;
    case ' ': {
      running = !running;
    } break;
    case 'r': {
      world.randomizeProperties();
    } break;
    default: {
      if(key>='0' && key<='9') {
        part_type = key-'0';
      }
    } break;
  }
}

void draw() {
  
  background(0);
  
  {
    final float mx = mouseX;
    final float my = mouseY;
    final float mr = 30;
    
    if(mousePressed) {
      
      final float mvx = (mouseX-pmouseX);
      final float mvy = (mouseY-pmouseY);
      
      if(mouseButton==LEFT) {
        
        for(int i=0;i<20;i++) {
          world.add(new Part(){{
            float range = sqrt(random(0,1))*mr;
            float angle = random(0,TWO_PI);
            x = mx+range*cos(angle);
            y = my+range*sin(angle);
            vx = mvx;
            vy = mvy;
            type = part_type;
          }});
        }
        
      } else {
        
        for(Part part : world) {
          float dx = mx - part.x;
          float dy = my - part.y;
          float dst2 = dx*dx+dy*dy;
          if(dst2<=mr*mr) {
            part.vx = mvx;
            part.vy = mvy;
          }
        }
        
      }
    } else {
      noFill();
      stroke(64);
      float d = mr*2;
      ellipse(mx,my,d,d);
    }
  }
  
  int steps = 3;
  float dt = 1./steps;
  
  if(running) {
    for(int i=0;i<steps;i++) {
      
      world.applyBorder(5,5,width-5,height-5);
      
      world.updateIDs();
      world.sortByIDs();
      world.resetIDGrid();
      world.updateIDGrid();
      
      world.clearNeighbors();
      world.updateNeighbors();
      
      world.shuffle();
      
      world.resetDensities();
      world.interact(Part.DENSITY);
      world.updatePressures();
      
      world.interact(0
        |Part.VISCOSITY
        |Part.PRESSURE
        |Part.SURFACE
        |Part.ADHESION
      );
      
      world.updateProperties(.05);
      
      world.move(dt);
    }
  }
  
  stroke(255);
  fill(255);
  world.draw(dt);
  
  surface.setTitle("FPS: "+frameRate);
}
