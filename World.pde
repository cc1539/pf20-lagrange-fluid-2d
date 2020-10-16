
public class World extends ArrayList<Part> {
  
  public Part.Properties[] properties = new Part.Properties[10]; // for each type
  public float[][] adhesion_matrix = new float[properties.length][properties.length];
  
  public float gravity = 5e-2;
  
  public int[][] grid;
  private int w;
  private int h;
  private float tile_size;
  
  public World(int w, int h, float tile_size) {
    this.w = w;
    this.h = h;
    this.tile_size = tile_size;
    grid = new int[w][h];
    
    for(int i=0;i<properties.length;i++) {
      properties[i] = new Part.Properties();
    }
  }
  
  public void randomizeProperties() {
    for(int i=0;i<properties.length;i++) {
      properties[i].m = random(1,2);
      properties[i].r = random(3,6);
      properties[i].u = random(5e-3,.5);
      properties[i].p0 = random(-1,7);
      properties[i].pF = random(1e-3,1e-1);
      properties[i].Tr = pow(random(0,1),2)*50;
      properties[i].Tf = min(properties[i].pF*2,pow(random(0,1),2)*1);
      colorMode(HSB);
      properties[i].shade = color(
          random(0,255),
          random(0,255),
          255);
    }
    for(int i=0;i<properties.length;i++) {
      adhesion_matrix[i][i] = 0;
      for(int j=i+1;j<properties.length;j++) {
        adhesion_matrix[i][j] = random(-1,2);
        adhesion_matrix[j][i] = adhesion_matrix[i][j];
      }
    }
  }
  
  public void updateIDs() {
    for(Part part : this) {
      part.id = (floor(part.x/tile_size)+floor(part.y/tile_size)*w);
    }
  }
  
  public void resetIDGrid() {
    for(int x=0;x<w;x++) {
    for(int y=0;y<h;y++) {
      grid[x][y] = -1;
    }
    }
  }
  
  public void sortByIDs() {
    Collections.sort(this,new Comparator<Part>(){
      public int compare(Part a, Part b) {
        return b.id-a.id;
      }
    });
  }
  
  public void updateIDGrid() {
    int last_id = -1;
    for(int i=0;i<size();i++) {
      Part part = get(i);
      if(part.id!=last_id) {
        last_id = part.id;
        grid[last_id%w][last_id/w] = i;
      }
    }
  }
  
  public void move(float dt) {
    for(Part part : this) {
      part.ay += gravity;
      part.move(dt);
    }
  }
  
  public void draw(float dt) {
    for(Part part : this) {
      part.draw(g,dt);
    }
  }
  
  public void shuffle() {
    for(int i=0;i<size();i++) {
      int j = (int)random(i,size());
      if(i!=j) {
        Part temp = get(i);
        set(i,get(j));
        set(j,temp);
      }
    }
  }
  
  public void interact(int options) {
    for(Part part : this) {
      part.interact(adhesion_matrix,options);
    }
  }
  
  public void resetDensities() {
    for(Part part : this) {
      part.resetDensity();
    }
  }
  
  public void updatePressures() {
    for(Part part : this) {
      part.updatePressure();
    }
  }
  
  public void updateNeighbors() {
    
    /*
    for(int i=0;i<size();i++) {
    for(int j=i+1;j<size();j++) {
      get(i).considerNeighbor(get(j));
    }
    }
    */
    
    for(Part part : this) {
      int x = part.id%w;
      int y = part.id/w;
      for(int i=-1;i<=1;i++) {
      for(int j=-1;j<=1;j++) {
        int u = x+i; if(u<0 || u>=w) { continue; }
        int v = y+j; if(v<0 || v>=h) { continue; }
        if(grid[u][v]!=-1) {
          int id = get(grid[u][v]).id;
          for(int k=grid[u][v];k<size()&&get(k).id==id;k++) {
            part.considerNeighbor(get(k));
          }
        }
      }
      }
    }
    
  }
  
  public void clearNeighbors() {
    for(Part part : this) {
      part.clearNeighbors();
    }
  }
  
  public void applyBorder(float x0, float y0, float x1, float y1) {
    for(Part part : this) {
      float x = part.x;
      float y = part.y;
      if(x<x0||x>x1){part.x=(x<x0?x0:x1)*2-x;part.vx*=-1;}
      if(y<y0||y>y1){part.y=(y<y0?y0:y1)*2-y;part.vy*=-1;}
    }
  }
  
  public void updateProperties(float rate) {
    for(Part part : this) {
      part.updateProperties(properties[part.type],rate);
    }
  }
  
}
