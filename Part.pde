
public static class Part {
  
  public static final int DENSITY   = 1<<0;
  public static final int VISCOSITY = 1<<1;
  public static final int PRESSURE  = 1<<2;
  public static final int SURFACE   = 1<<3;
  public static final int ADHESION  = 1<<4;
  
  public ArrayList<Part> neighbors = new ArrayList<Part>();
  
  public float x,vx,ax;
  public float y,vy,ay;
  
  public static class Properties {
    
    public float m = 1; // mass
    public float r = 5; // interaction radius
    public float u = 2e-2; // viscosity
    public float p0 = 5.5; // target pressure
    public float pF = 1e-2; // pressure force
    public float Tr = 30; // surface tension range
    public float Tf = 1e-1; // surface tension force
    public color shade;
    
    public void lerp(Properties target, float rate) {
      m += (target.m-m)*rate;
      r += (target.r-r)*rate;
      u += (target.u-u)*rate;
      p0 += (target.p0-p0)*rate;
      pF += (target.pF-pF)*rate;
      Tr += (target.Tr-Tr)*rate;
      Tf += (target.Tf-Tf)*rate;
      color new_shade = applet.lerpColor(shade,target.shade,rate);
      shade = (new_shade!=shade)?target.shade:new_shade;
    }
    
  }
  
  public Properties props = new Properties();
  
  public float d; // density
  public float p; // pressure
  
  public int type;
  public int id;
  
  public void considerNeighbor(Part part) {
    
    if(part==this) { return; }
    
    if(this.neighbors.contains(part)) { return; }
    if(part.neighbors.contains(this)) { return; }
    
    float dx = this.x - part.x;
    float dy = this.y - part.y;
    
    float rads = this.props.r+part.props.r;
    float dst2 = dx*dx+dy*dy;
    
    if(dst2<rads*rads) {
      neighbors.add(part);
    }
    
  }
  
  public void clearNeighbors() {
    neighbors.clear();
  }
  
  public void interact(float[][] adhesion_matrix, int options) {
    for(Part part : neighbors) {
      interact(part,adhesion_matrix,options);
    }
  }
  
  public void resetDensity() {
    d = props.m;
  }
  
  public void updatePressure() {
    p = d;
  }
  
  void move(float dt) {
    x += (vx += ax*dt)*dt; ax=0;
    y += (vy += ay*dt)*dt; ay=0;
  }
  
  void draw(PGraphics g, float dt) {
    g.stroke(props.shade);
    int x = (int)this.x;
    int y = (int)this.y;
    int vx = (int)(this.vx*dt);
    int vy = (int)(this.vy*dt);
    if(abs(vx)>1 || abs(vy)>1) {
      g.line(x,y,x+vx,y+vy);
    } else {
      g.point(x,y);
    }
  }
  
  void interact(Part part, float[][] adhesion_matrix, int options) {
    
    float dx = this.x - part.x;
    float dy = this.y - part.y;
    
    float rads = this.props.r+part.props.r;
    float dst2 = dx*dx+dy*dy;
    
    float dst = sqrt(dst2);
    float h = 1-rads/dst; // asymptotic
    float q = 1-dst/rads; // linear
    
    float force = 0;
    
    if((options&DENSITY)!=0) {
      this.d += part.props.m*q;
      part.d += this.props.m*q;
    }
    
    if(dst2>0) {
      
      if((options&VISCOSITY)!=0) {
        float u = min(this.props.u,part.props.u);
        force += (
            (part.vx-this.vx)*dx+
            (part.vy-this.vy)*dy)/dst2*u;//*-h;
      }
      
      if((options&PRESSURE)!=0) {
        force += (
            (this.props.p0-this.p)*this.props.pF+
            (part.props.p0-part.p)*part.props.pF)*h;
      }
      
      if((options&SURFACE)!=0) {
        float Tr = min(this.props.Tr,part.props.Tr);
        float Tf = min(this.props.Tf,part.props.Tf);
        force -= q*max(0,1-(min(this.d,part.d))/Tr)*Tf;
      }
      
      if((options&ADHESION)!=0) {
        if(this.type!=part.type) {
          force -= adhesion_matrix[this.type][part.type]/(dst2/rads+1);
        }
      }
      
    }
    
    if(force!=0) {
      dx*=force; this.ax+=dx; part.ax-=dx;
      dy*=force; this.ay+=dy; part.ay-=dy;
    }
    
  }
  
  public void updateProperties(Properties props, float rate) {
    this.props.lerp(props,rate);
  }
  
}
