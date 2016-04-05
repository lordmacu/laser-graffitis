/**
 * Draws a set of lines with drips.
 */

class DripsScreen {
  protected GeneralPath draw_path;
  protected float[] current_point = new float[2];
  protected float[] previous_point = new float[2];
  protected ArrayList drips;
  protected int colour;
  
  public DripsScreen(int colour){
    clear();
    this.colour = colour;
  }

  public void draw_rotate(){
    pushMatrix();
    translate(width/2, height/2);
    
    if (!should_draw_left) {
      rotateY(crap);
    } else {
      rotateX(-crap);
    };
    
    fill(colour);
    noStroke();    
    strokeWeight(1);
    
    PathIterator i = draw_path.getPathIterator(new AffineTransform());
    int segment_type;
    float z = -50.0;
    float zo = z;
    float az = 0.0;
    float[] old = new float[2];
    float[] p = new float[2];
    boolean wasLineSegment = false;
    while(!i.isDone()){

      segment_type = i.currentSegment(p);
       //crap += 0.1;
       //noFill();
       //box(200);
       //fill(255);
      //rotateX(crap);
      //rotateY(crap);
      if(segment_type == PathIterator.SEG_LINETO && !wasLineSegment) {
        beginShape(TRIANGLE_STRIP);
        wasLineSegment = true;
      }
      if(segment_type == PathIterator.SEG_MOVETO && wasLineSegment) {
        endShape();
        wasLineSegment = false;
      }
      if(segment_type == PathIterator.SEG_LINETO) {
      if (wannarotate) {
          p[0] = p[0]-(width/2);
          p[1] = p[1]-(height/2);
      }

          vertex(p[0]+brush_width, p[1]+brush_width, z); // A
          vertex(p[0]-brush_width, p[1]-brush_width, z); // D
      }

     //if (old_segment_type != PathIterator.SEG_MOVETO) {
      zo = z;
      z += 1.5;
      //if (old[0] != p[0] && old[1] != p[1]) {
      //println(old[0]);
      old[0] = p[0];
      old[1] = p[1];
      // }
      //}

      //old_segment_type = segment_type;

      i.next();
    }
    
    if(wasLineSegment){
      endShape();
      wasLineSegment = false;
    }
    
    popMatrix();
  }
  
  public void draw(){
    //all done in update() for increased performance    
    noFill();
    stroke(colour);
    fill(colour);
    strokeWeight(1);
    //strokeCap(ROUND);
    
    Vector2d vec;
    Vector2d vec2;
    float xdiff;
    float ydiff;
    double[] vecf = new double[2];
    double[] vec2f = new double[2];
    float[] current_point = new float[2];
    float[] previous_point = new float[2];
    int segment_type;
    PathIterator pi = draw_path.getPathIterator(new AffineTransform());
    while(!pi.isDone()){
      segment_type = pi.currentSegment(current_point);

      if(segment_type == PathIterator.SEG_LINETO){
        
        if(should_draw_fatmarker){

          //caluclate normal vector
          xdiff = previous_point[0] - current_point[0];
          ydiff = previous_point[1] - current_point[1];
          
          if(xdiff == 0 && ydiff == 0){
            ellipse(current_point[0], current_point[1], brush_width*2, brush_width*2);
          }
          else{
            vec = new Vector2d(-ydiff, xdiff); //swap x & y for normal vector
            vec.normalize();
            vec.get(vecf);

            vec2 = new Vector2d(xdiff, ydiff); //direction of our stroke
            vec2.normalize();
            vec2.get(vec2f);
            
            noStroke();
            fill(colour);
   //stroke(255);
//noFill();
            beginShape();
            vertex((float)(previous_point[0]+vecf[0]*brush_width), (float)(previous_point[1]+vecf[1]*brush_width));

            vertex((float)(current_point[0]+vecf[0]*brush_width), (float)(current_point[1]+vecf[1]*brush_width));
            vertex((float)(current_point[0]-vecf[0]*brush_width), (float)(current_point[1]-vecf[1]*brush_width));

            vertex((float)(previous_point[0]-vecf[0]*brush_width), (float)(previous_point[1]-vecf[1]*brush_width));

            //back to start (do we need this?)
            //vertex((float)(previous_point[0]+vecf[0]*brush_width), (float)(previous_point[1]+vecf[1]*brush_width)); //back to start point
            endShape();
            
            ellipse(current_point[0], current_point[1], brush_width*2, brush_width*2);
            ellipse(previous_point[0], previous_point[1], brush_width*2, brush_width*2);
          }
        }
        else{ //slant marker
          beginShape();
          vertex(previous_point[0]+brush_width, previous_point[1]+brush_width);
          vertex(current_point[0]+brush_width, current_point[1]+brush_width);
          vertex(current_point[0]-brush_width, current_point[1]-brush_width);
          vertex(previous_point[0]-brush_width, previous_point[1]-brush_width);
          //vertex(previous_point[0]+brush_width, previous_point[1]+brush_width); //back to start - needed?
          endShape();
        }
      }

      previous_point[0] = current_point[0];
      previous_point[1] = current_point[1];
      pi.next();
    }
    
    if(should_draw_drips){
      Iterator i = drips.iterator();
      Drip d;
      while(i.hasNext()){
        d = (Drip)i.next();
        d.draw();
      }
    }
  }
    
  public void update(int x, int y, boolean line){
    previous_point[0] = current_point[0];
    previous_point[1] = current_point[1];
    current_point[0] = x;
    current_point[1] = y;

    if(line){ 
      if(new_drip())
        drips.add(new Drip((int)current_point[0], (int)current_point[1], (int)random(0, height/3)));
    }
  }

  public boolean new_drip(){
    if((int)random(0,drips_probability) == 0)
      return true;
    else
      return false;
  }

  public void moveTo(int x, int y){
    draw_path.moveTo(x, y);
    update(x,y,false);
  }
  
  public void lineTo(int x, int y){
    draw_path.lineTo(x, y);
    update(x,y,true);
  }
  
  public void clear(){
    drips = new ArrayList();
    draw_path = new GeneralPath();
    draw_path.moveTo(0,0);
  }
}


class Drip {
  int ttl_start;
  int ttl;
  int x;
  int y;
  int drip_width;

  public Drip(int x, int y, int ttl){
    this.x = x;
    this.y = y;
    this.ttl = ttl;
    this.ttl_start = ttl;
    this.drip_width = (int)(brush_width/3);
  }
  
  public void draw(){
    if (!should_draw_left) {
      quad(x-drip_width/2, y-drip_width/2,
          x+drip_width/2, y+drip_width/2,
          x+drip_width/2, y+(ttl_start-ttl),
          x-drip_width/2, y+(ttl_start-ttl));
      ellipse(x, y+(ttl_start-ttl), drip_width-2, drip_width-2);
    } else {
      quad(x+drip_width/2, y-drip_width/2,
          x-(ttl_start-ttl), y-drip_width/2,
          x-(ttl_start-ttl), y+drip_width/2,
          x-drip_width/2, y+drip_width/2);
      ellipse(x-(ttl_start-ttl), y, drip_width-2, drip_width-2);
    };
    
    if(!is_dead())
      ttl -= 1;
  }
  
  public boolean is_dead(){
    return ttl < 0;
  }
}
